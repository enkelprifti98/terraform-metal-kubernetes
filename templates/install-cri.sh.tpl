#!/bin/bash
# vim: syntax=sh

echo "[----- Begin install-cri.sh ----]"

echo "Installing Containerd"

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections

### Install packages to allow apt to use a repository over HTTPS
apt-get update \
  && apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

apt-get install -y containerd

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
systemctl restart containerd

echo "[----- install-cri.sh Complete ------]"
