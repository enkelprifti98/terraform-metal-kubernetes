data "template_file" "cluster_autoscaler_secret_yaml" {

  count = var.cluster_autoscaler == "enabled" ? 1 : 0

  template = file("${path.module}/templates/cluster-autoscaler/cluster-autoscaler-secret.yaml")

  vars = {
    EQUINIX_METAL_API_TOKEN   = "${base64encode(var.auth_token)}"
    EQUINIX_METAL_PROJECT_ID  = equinix_metal_project.kubenet.id
    FACILITY                  = var.cluster_autoscaler_facility
    PLAN                      = var.worker_plan
    KUBERNETES_API_IP_ADDRESS = equinix_metal_device.k8s_controller.access_private_ipv4
    KUBERNETES_API_PORT       = var.kubernetes_port
  }
}

resource "null_resource" "cluster_autoscaler" {

  count = var.cluster_autoscaler == "enabled" ? 1 : 0

  connection {
    type = "ssh"
    user = "root"
    host = equinix_metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/templates/cluster-autoscaler/cluster-autoscaler-svcaccount.yaml"
    destination = "/tmp/cluster-autoscaler-svcaccount.yaml"
  }

  provisioner "file" {
    content     = data.template_file.cluster_autoscaler_secret_yaml[0].rendered
    destination = "/tmp/cluster-autoscaler-secret.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/cluster-autoscaler/cluster-autoscaler-deployment.yaml"
    destination = "/tmp/cluster-autoscaler-deployment.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/cluster-autoscaler/kubeadm_join_token.sh"
    destination = "/tmp/kubeadm_join_token.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kubeadm_join_token.sh",
      "/tmp/kubeadm_join_token.sh",
      "sed -i \"s/CLUSTER_AUTOSCALER_VERSION/${var.cluster_autoscaler_version}/g\" /tmp/cluster-autoscaler-deployment.yaml",
      "kubectl apply -f /tmp/cluster-autoscaler-svcaccount.yaml",
      "kubectl apply -f /tmp/cluster-autoscaler-secret.yaml",
      "kubectl apply -f /tmp/cluster-autoscaler-deployment.yaml"
    ]
  }

  depends_on = [
    null_resource.ccm_kubevip,
    null_resource.ccm_metallb,
    null_resource.ccm_metallb_legacy
  ]
}
