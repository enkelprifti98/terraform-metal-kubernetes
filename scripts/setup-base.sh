#!/bin/bash

echo "[------ Begin setup-base.sh -----]"

# Base kubernetes requirements
echo "Enable Forwarding"

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

echo "Disable swap"
swapoff -a
sed -i.bak '/swap/s/^/#/g' /etc/fstab

# Verify
cat /proc/swaps

# Install jq
apt-get install -y jq

echo "[----- setup-base.sh Complete -----]"
