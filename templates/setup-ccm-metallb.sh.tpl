#!/bin/bash
# vim: syntax=sh

# This is needed to allow alias creation in bash scripts which we are using for kube-vip
shopt -s expand_aliases


echo "[----- Setting up Equinix Metal CCM ----]"

cat <<EOF >equinix-secret-config.yaml
apiVersion: v1
kind: Secret
metadata:
  name: metal-cloud-config
  namespace: kube-system
stringData:
  cloud-sa.json: |
    {
      "apiKey": "${API-TOKEN}",
      "projectID": "${PROJECT-ID}",
      "loadbalancer": "metallb:///"
    }
EOF

kubectl apply -f equinix-secret-config.yaml

kubectl apply -f https://github.com/equinix/cloud-provider-equinix-metal/releases/download/${CCM-RELEASE}/deployment.yaml


echo "[----- Setting up MetalLB ----]"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB-RELEASE}/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB-RELEASE}/manifests/metallb.yaml

cat <<EOF >metallb-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    peers:
EOF

kubectl apply -f metallb-configmap.yaml
