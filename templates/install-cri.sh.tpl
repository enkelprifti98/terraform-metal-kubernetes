#!/bin/bash
# vim: syntax=sh

echo "[----- Begin install-cri.sh ----]"

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections

### Install packages to allow apt to use a repository over HTTPS
apt-get update \
  && apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

echo "[----- Begin installing Docker CE ----]"

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) \
  stable"

## Install Docker CE
apt-get update \
  && apt-get install -y \
  docker-ce

# Setup daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker
systemctl daemon-reload
systemctl restart docker

echo "[----- Begin configuring Containerd ----]"

# Configure Containerd for Kubernetes CRI

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
systemctl restart containerd


echo "[----- install-cri.sh Complete ------]"
