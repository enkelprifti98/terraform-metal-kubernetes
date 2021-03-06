#!/bin/bash
# vim: syntax=sh

HOSTNAME=$(hostname -s)
LOCAL_IP=$(ip a | grep "inet 10" | cut -d" " -f6 | cut -d"/" -f1)

echo "[----- Setting up Kubernetes using kubeadm ----]"

kubeadm init \
--apiserver-advertise-address $LOCAL_IP \
--apiserver-bind-port ${kubernetes_port} \
--cri-socket unix:///run/containerd/containerd.sock \
--image-repository k8s.gcr.io \
--kubernetes-version v${kubernetes_version} \
--node-name $HOSTNAME \
--pod-network-cidr ${kubernetes_cluster_cidr} \
--service-cidr ${kubernetes_service_cidr} \
--service-dns-domain ${kubernetes_dns_domain}

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[---- Done setting up kubernetes -----]"
