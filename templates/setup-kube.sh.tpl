#!/bin/bash

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections

HOSTNAME=$(hostname -s)
# Get Packet server's private IP address
LOCAL_IP=$(ip a | grep "inet 10" | cut -d" " -f6 | cut -d"/" -f1)

get_version () {
	PACKAGE=$1
	VERSION=$2
	apt-cache madison $PACKAGE | grep $VERSION | head -1 | awk '{print $3}'
}

echo "[----- Setting up kubernetes configurations -----]"

apt-get update
apt-get install -y apt-transport-https ca-certificates curl

#THIS REPOSITORY KEY NO LONGER WORKS
#curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Referring to https://github.com/kubernetes/k8s.io/pull/4837

#They have updated their host address, so now we should update it to use the key from https://dl.k8s.io/apt/doc/apt-key.gpg. Then use something like:

#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Don't add trusted=yes! This is dangerous and will tell apt to ignore the result of key verification.

#THE FOLLOWING WORKS AS WELL
#curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
#echo 'deb https://packages.cloud.google.com/apt kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y \
	kubelet=$(get_version kubelet ${kubernetes_version}) \
	kubeadm=$(get_version kubeadm ${kubernetes_version}) \
	kubectl=$(get_version kubectl ${kubernetes_version}) \
	cri-tools

# Make the kubelet use only the private IP to run it's management controller pods
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$LOCAL_IP --address=$LOCAL_IP --cloud-provider=external\"" > /etc/default/kubelet

echo "[---- Done setting up kubernetes configurations -----]"
