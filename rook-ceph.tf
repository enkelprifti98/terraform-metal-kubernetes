resource "null_resource" "rook_ceph" {

  count = var.storage == "rook-ceph" ? 1 : 0

  depends_on = [null_resource.setup_worker]
  
  connection {
    type = "ssh"
    user = "root"
    host = equinix_metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/deploy/examples/crds.yaml"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/deploy/examples/common.yaml"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/deploy/examples/operator.yaml"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 5",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/deploy/examples/cluster.yaml"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 5",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/deploy/examples/csi/rbd/storageclass.yaml"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 5",
      "kubectl patch storageclass rook-ceph-block -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'"
    ]
  }

  /*provisioner "file" {
    source      = "${path.module}/templates/wait-for-rook-ceph-cluster-creation.sh.tpl"
    destination = "/tmp/wait-for-rook-ceph-cluster-creation.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 5",
      "chmod +x /tmp/wait-for-rook-ceph-cluster-creation.sh",
      "/tmp/wait-for-rook-ceph-cluster-creation.sh"
    ]
  }*/

}
