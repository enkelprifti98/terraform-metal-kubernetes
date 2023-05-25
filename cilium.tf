data "template_file" "cilium" {

    count = var.cni == "Cilium" ? 1 : 0

    template = file("${path.module}/scripts/install-cilium.sh")
    vars = {
        cilium_cli_version = var.cilium_cli_version
        cilium_version = var.cilium_version
   }
}

resource "null_resource" "setup_cilium" {

  count = var.cni == "Cilium" ? 1 : 0

  connection {
    type = "ssh"
    user = "root"
    host = equinix_metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    content     = data.template_file.cilium[0].rendered
    destination = "/tmp/install-cilium.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-cilium.sh",
      "/tmp/install-cilium.sh"
    ]
  }

  depends_on = [equinix_metal_device.k8s_controller]
}
