variable "auth_token" {
  description = "Your Equinix Metal API key"
}

variable "organization_id" {
  description = "Your Equinix Metal organization where the project k8s-bgp will be created"
}

variable "project_name" {
  description = "The project name, k8s-bgp is used as default if not specified"
  default = "k8s-bgp"
}

variable "BGP_Password" {
  description = "The project BGP password, empty string is no password"
  default = ""
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  default     = "1.30.3"
}

variable "cni" {
  description = "Kubernetes Container Network Interface, choice of Calico and Cilium or empty string for none"
  default     = "Cilium"
}

variable "calico_version" {
  description = "Calico Version"
  default     = "v3.28.1"
}

variable "calicoctl_version" {
  description = "Calicoctl Version"
  default     = "v3.28.1"
}

variable "cilium_cli_version" {
  description = "Cilium CLI Version used to install Cilium CNI"
  default     = "v0.16.15"
}

variable "cilium_version" {
  description = "Cilium Version"
  default     = "v1.16.0"
}

variable "ccm_release" {
  description = "Equinix Metal CCM Version"
  default     = "v3.8.1"
}

variable "service_loadbalancer" {
  description = "Kubernetes Service Load Balancer, choice of Kube-VIP, MetalLB, MetalLB-legacy (for versions <= 0.12.1) or empty string for none"
  default     = "MetalLB"
}

variable "kube_vip_release" {
  description = "Kube-VIP Version"
  default     = "v0.8.0"
}

variable "metallb_release" {
  description = "MetalLB Version"
  default     = "v0.14.8"
}

variable "storage" {
  description = "Shared storage option of rook-ceph or empty string for none"
  default     = "rook-ceph"
}

variable "rook_ceph_version" {
  description = "Rook Ceph Version"
  default     = "v1.14.9"
}

variable "kubernetes_port" {
  description = "Kubernetes API Port"
  default = "6443"
}

variable "kubernetes_dns_ip" {
  description = "Kubernetes DNS IP"
  default = "192.168.0.10"
}

variable "kubernetes_cluster_cidr" {
  description = "Kubernetes Cluster Subnet"
  default     = "172.16.0.0/12"
}

variable "kubernetes_service_cidr" {
  description = "Kubernetes Service Subnet"
  default     = "192.168.0.0/16"
}

variable "kubernetes_dns_domain" {
  description = "Kubernetes Internal DNS Domain"
  default     = "cluster.local"
}

variable "cluster_autoscaler" {
  description = "Equinix Metal Cluster Autoscaler for Kubernetes"
  default = "disabled"
}

variable "cluster_autoscaler_version" {
  description = "Equinix Metal Cluster Autoscaler version for Kubernetes"
  default = "v1.27.1"
}

variable "cluster_autoscaler_facility" {
  description = "Facility used for Equinix Metal Cluster Autoscaler for Kubernetes"
  default = "dc13"
}
