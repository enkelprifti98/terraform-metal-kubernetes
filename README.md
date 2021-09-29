![](https://img.shields.io/badge/Stability-Experimental-red.svg)

Kubernetes on Equinix Metal
===========================

This guide can be used as a reference to deploy Kubernetes on Equinix Metal bare-metal servers in a single facility.  This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

| Component  | Version |
| ---------- | ------- |
| Kubernetes | v1.22.2 |
| Calico     | v3.20.0 |
| CCM        | v3.2.2  |
| MetalLB    | v0.10.2 |
| Kube-VIP   | v0.3.8  |
| Rook-Ceph  | v1.7.4  |

Kubernetes Network:

| Network                  | Subnet           |
| ------------------------ | ---------------- |
| Pod subnet               | 172.16.0.0/12    |
| Service subnet           | 192.168.0.0/16   |


This Terraform script will deploy a cluster of 4, 1 controller and 3 worker nodes. It will allow you to use the service type `LoadBalancer` and make Persistent Volume Claims.

Quickstart
------------------------

Make a copy of `terraform.tfvars.sample` as `terraform.tfvars`  and set the `auth_token` as well as `organization_id`. You can also configure other options like the server type, amount of worker nodes, kubernetes version etc.

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

Run the Terraform script to deploy the cluster:

```sh
terraform apply
```

Once the script has completed, you will be given the controller and node addresses.

You can now use the kubernetes service type `LoadBalancer` and you will be assigned a Public External IP.

For example, we can deploy wordpress which makes use of service type `LoadBalancer` along with persistent volume claims.
 
Here we are using the deployment from the rook-ceph [guide](https://rook.io/docs/rook/v1.7/ceph-block.html#consume-the-storage-wordpress-sample).

Run the following:

```sh
kubectl create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/mysql.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/wordpress.yaml
```

You can check the persistent volume claim requests:

`kubectl get pvc`

Then check the persistent volumes:

`kubectl get pv`

Lastly, check the service of type `LoadBalancer:

`kubectl get svc wordpress`

Get the external IP address and check if it is reachable through your web browser, if the deployment was successful you should see the wordpress app.
