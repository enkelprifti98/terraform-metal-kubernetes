#!/bin/bash

KUBEADM_JOIN_TOKEN_ID=$(kubeadm token list | awk '{print $1}' | sed -n '2p' | cut -d "." -f 1)
KUBEADM_JOIN_TOKEN_SECRET=$(kubeadm token list | awk '{print $1}' | sed -n '2p' | cut -d "." -f 2)
sed -i "s/TOKEN_ID/$KUBEADM_JOIN_TOKEN_ID/g" /tmp/cluster-autoscaler-secret.yaml
sed -i "s/TOKEN_SECRET/$KUBEADM_JOIN_TOKEN_SECRET/g" /tmp/cluster-autoscaler-secret.yaml
