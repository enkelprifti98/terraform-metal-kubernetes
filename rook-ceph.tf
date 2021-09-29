resource "null_resource" "rook_ceph" {

  count = var.storage == "rook-ceph" ? 1 : 0

  connection {
    type = "ssh"
    user = "root"
    host = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/templates/wait-for-rook-ceph-cluster-creation.sh.tpl"
    destination = "/tmp/wait-for-rook-ceph-cluster-creation.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/cluster/examples/kubernetes/ceph/crds.yaml",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/cluster/examples/kubernetes/ceph/common.yaml",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/cluster/examples/kubernetes/ceph/operator.yaml",
      "sleep 5",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/cluster/examples/kubernetes/ceph/cluster.yaml", 
      "sleep 5",
      "kubectl create -f https://raw.githubusercontent.com/rook/rook/${var.rook_ceph_version}/cluster/examples/kubernetes/ceph/csi/rbd/storageclass.yaml",
      "sleep 5",
      "kubectl patch storageclass rook-ceph-block -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'",
      "chmod +x /tmp/wait-for-rook-ceph-cluster-creation.sh",
      "/tmp/wait-for-rook-ceph-cluster-creation.sh"
    ]
  }

  depends_on = [null_resource.setup_worker]
}
