terraform {
 required_providers {
    metal = {
      source = "equinix/metal"
# Version is not required, not specifying it will use the latest provider version
#      version = "2.7.4"
    }
  }
# Required_version is not required
#  required_version = ">= 0.13"
}

provider "metal" {
  auth_token = var.auth_token
}

resource "metal_project" "kubenet" {
  organization_id = var.organization_id
  
  name = var.project_name

  bgp_config {
    deployment_type = "local"
    md5 = var.BGP_Password
    asn = 65000
}
  
}

resource "metal_ssh_key" "k8s-cluster-key" {
  name       = "k8s-bgp-cluster-access-key"
  public_key = tls_private_key.k8s_cluster_access_key.public_key_openssh
}

variable "metro" {
  default = "dc"
}

variable "worker_count" {
  default = 2
}

variable "controller_plan" {
  description = "Set the Equinix Metal server type for the controller"
  default     = "c3.medium.x86"
}

variable "worker_plan" {
  description = "Set the Equinix Metal server type for the workers"
  default     = "c3.medium.x86"
}

// General template used to install the container runtime interface
data "template_file" "install_cri" {
  template = file("${path.module}/templates/install-cri.sh.tpl")
}

data "template_file" "install_kubernetes" {
  template = file("${path.module}/templates/setup-kube.sh.tpl")

  vars = {
    kubernetes_version = var.kubernetes_version
  }
}
