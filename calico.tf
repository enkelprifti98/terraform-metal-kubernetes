data "template_file" "calico" { 
    template = file("${path.module}/scripts/install-calico.sh")
    vars = {
        calico_version = var.calico_version
        calicoctl_version = var.calicoctl_version
   }
}

resource "null_resource" "setup_calico" {
  connection {
    type = "ssh"
    user = "root"
    host = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    content     = data.template_file.calico.rendered
    destination = "/tmp/install-calico.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-calico.sh",
      "/tmp/install-calico.sh"
    ]
  }

  depends_on = [metal_device.k8s_controller]
}
