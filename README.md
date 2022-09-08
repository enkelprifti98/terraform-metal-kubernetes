![](https://img.shields.io/badge/Stability-Experimental-red.svg)

Kubernetes on Equinix Metal
===========================

This guide can be used as a reference to deploy Kubernetes on Equinix Metal bare-metal servers in a single Metro.  This repository is experimental meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and I strongly encourage you to NOT use this in production.

| Component  | Version |
| ---------- | ------- |
| Kubernetes | v1.24.1 |
| Calico     | v3.24.1 |
| CCM        | v3.4.3  |
| MetalLB    | v0.12.1 |
| Kube-VIP   | v0.4.2  |
| Rook-Ceph  | v1.9.4  |

Kubernetes Network:

| Network                  | Subnet           |
| ------------------------ | ---------------- |
| Pod subnet               | 172.16.0.0/12    |
| Service subnet           | 192.168.0.0/16   |


This Terraform script will deploy a cluster of 4, 1 controller and 3 worker nodes. It will allow you to use the service type `LoadBalancer` and make Persistent Volume Claims.


## Prerequisites

To use these Terraform files, you need to have the following Prerequisites:

- An Equinix Metal organization ID and [API key](https://metal.equinix.com/developers/api/)
- `unzip` and `jq` packages installed on the local host that will be running the script. On Ubuntu you can install these with `apt-get install -y unzip jq`.


### Install Terraform

Terraform is just a single binary. Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path.

Here is an example for **MacOS**:

```bash
curl -LO https://releases.hashicorp.com/terraform/1.1.6/terraform_1.1.6_darwin_amd64.zip
unzip terraform_1.1.6_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
rm -f terraform_1.1.6_darwin_amd64.zip
```

Here is an example for **Linux**:

```bash
curl -LO https://releases.hashicorp.com/terraform/1.1.6/terraform_1.1.6_linux_amd64.zip
unzip terraform_1.1.6_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
rm -f terraform_1.1.6_linux_amd64.zip
```

## Download this project

To download this project, run the following command:

```bash
git clone https://github.com/enkelprifti98/terraform-metal-kubernetes.git
cd terraform-metal-kubernetes
```

## Initialize Terraform

Terraform uses modules to deploy infrastructure. In order to initialize the modules simply run:

```sh
terraform init
```

This should download several modules into a hidden directory `.terraform`.


## Configure your variables

Make a copy of `terraform.tfvars.sample` as `terraform.tfvars`  and set the `auth_token` as well as `organization_id`. You can also configure other options like the server type, amount of worker nodes, etc.

```sh
auth_token = "METAL_AUTH_TOKEN"
organization_id = "METAL_ORG_ID"
project_name = "k8s-bgp"
metro = "dc"
controller_plan = "c3.medium.x86"
worker_plan = "c3.medium.x86"
worker_count = 3
```

Note: There is also a `terraform.tfvars.sample.custom` file in this repo that you can use. It has more configuration options for the cluster.

## Deploy the cluster

Run the Terraform script to deploy the cluster:

```sh
terraform apply
```

Once the script has completed, you will be given the controller and node addresses.

## Testing

You can now use the kubernetes service type `LoadBalancer` and you will be assigned a Public External IP.

For example, we can deploy wordpress which makes use of service type `LoadBalancer` along with persistent volume claims.
 
Here we are using the deployment from the rook-ceph [guide](https://rook.io/docs/rook/v1.7/ceph-block.html#consume-the-storage-wordpress-sample).

Run the following:

```sh
kubectl create -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/mysql.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/wordpress.yaml
```

You can check the persistent volume claim requests:

`kubectl get pvc`

Then check the persistent volumes:

`kubectl get pv`

Lastly, check the wordpress service of type LoadBalancer:

`kubectl get svc wordpress`

Get the external IP address and check if it is reachable through your web browser, if the deployment was successful you should see the wordpress app.
