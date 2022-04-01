data "template_file" "setup_ccm_kubevip" {

  count = var.service_loadbalancer == "Kube-VIP" ? 1 : 0

  template = file("${path.module}/templates/setup-ccm-kubevip.sh.tpl")

  vars = {
    API-TOKEN         = var.auth_token
    PROJECT-ID        = metal_project.kubenet.id
    METRO             = var.metro
    CCM-RELEASE       = var.ccm_release
    KUBE-VIP-RELEASE  = var.kube_vip_release
  }
}

resource "null_resource" "ccm_kubevip" {

  count = var.service_loadbalancer == "Kube-VIP" ? 1 : 0

  connection {
    type = "ssh"
    user = "root"
    host = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    content     = data.template_file.setup_ccm_kubevip[0].rendered
    destination = "/tmp/setup-ccm-kubevip.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-ccm-kubevip.sh",
      "/tmp/setup-ccm-kubevip.sh"
    ]
  }

  depends_on = [null_resource.setup_calico]
}
