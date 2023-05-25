resource "equinix_metal_device" "k8s_workers" {
  project_id       = equinix_metal_project.kubenet.id
  metro            = var.metro
  count            = var.worker_count
  plan             = var.worker_plan
  operating_system = "ubuntu_22_04"
  hostname         = format("%s-%s-%d", var.metro, "worker", count.index)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "worker", "k8s-cluster-cluster1", "k8s-nodepool-pool1"]
}

resource "equinix_metal_bgp_session" "workers_bgp" {
  count          = var.worker_count
  device_id      = element(equinix_metal_device.k8s_workers.*.id, count.index)
  address_family = "ipv4"
}

# Using a null_resource so the metal_device doesn't not have to wait to be initially provisioned
resource "null_resource" "setup_worker" {
  count = var.worker_count

  connection {
    type = "ssh"
    user = "root"
    host = element(equinix_metal_device.k8s_workers.*.access_public_ipv4, count.index)
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-base.sh"
    destination = "/tmp/setup-base.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_cri.rendered
    destination = "/tmp/install-cri.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_kubernetes.rendered
    destination = "/tmp/setup-kube.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bgp-routes.sh"
    destination = "/tmp/bgp-routes.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-cri.sh",
      "/tmp/setup-kube.sh",
      data.external.kubeadm_join.result.command,

# Only enable the execution of the bgp-routes.sh script if you see issues with BGP peering
# Some BGP speakers will not respect source routing so adding static routes can help.
# This is needed for Kube-vip and MetalLB to be able to establish BGP sessions.

      "/tmp/bgp-routes.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get nodes -o wide",
    ]

    on_failure = continue

    connection {
      type = "ssh"
      user = "root"
      host = equinix_metal_device.k8s_controller.access_public_ipv4
      private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
    }
  }
}

# We need to get the private IPv4 Gateway of each worker
data "external" "private_ipv4_gateway" {
  count   = var.worker_count
  program = ["${path.module}/scripts/gateway.sh"]

  query = {
    host = element(equinix_metal_device.k8s_workers.*.access_public_ipv4, count.index)
  }
}
