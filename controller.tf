variable "hostname" {
  default = "controller"
}

// Setup the kubernetes controller node
resource "equinix_metal_device" "k8s_controller" {
  project_id       = equinix_metal_project.kubenet.id
  metro            = var.metro
  plan             = var.controller_plan
  operating_system = "ubuntu_22_04"
  hostname         = format("%s-%s", var.metro, var.hostname)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "controller"]

  connection {
    type = "ssh"
    user = "root"
    host = equinix_metal_device.k8s_controller.access_public_ipv4
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
    content     = data.template_file.setup_kubeadm.rendered
    destination = "/tmp/setup-kubeadm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-cri.sh",
      "/tmp/setup-kube.sh",
      "/tmp/setup-kubeadm.sh"
    ]
  }
}

resource "equinix_metal_bgp_session" "controller_bgp" {
  device_id      = equinix_metal_device.k8s_controller.id
  address_family = "ipv4"
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-token.sh"]

  query = {
    host = equinix_metal_device.k8s_controller.access_public_ipv4
  }

  # Make sure to only run this after the controller is up and setup
  depends_on = [equinix_metal_device.k8s_controller]
}

data "template_file" "setup_kubeadm" {
  template = file("${path.module}/templates/setup-kubeadm.sh.tpl")

  vars = {
    kubernetes_version      = var.kubernetes_version
    kubernetes_port         = var.kubernetes_port
    kubernetes_dns_ip       = var.kubernetes_dns_ip
    kubernetes_dns_domain   = var.kubernetes_dns_domain
    kubernetes_cluster_cidr = var.kubernetes_cluster_cidr
    kubernetes_service_cidr = var.kubernetes_service_cidr
  }
}
