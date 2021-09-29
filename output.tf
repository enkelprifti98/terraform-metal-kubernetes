output "controller_address" {
  value = [metal_device.k8s_controller.access_public_ipv4]
}

output "kubeadm_join_command" {
  value = [data.external.kubeadm_join.result["command"]]
}

output "worker_addresses" {
  value = [metal_device.k8s_workers.*.access_public_ipv4]
}
