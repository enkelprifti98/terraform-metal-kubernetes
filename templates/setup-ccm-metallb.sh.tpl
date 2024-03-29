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
      "metro": "${METRO}",
      "loadbalancer": "metallb:///?crdConfiguration=true"
    }
EOF

kubectl apply -f equinix-secret-config.yaml

kubectl apply -f https://github.com/equinix/cloud-provider-equinix-metal/releases/download/${CCM-RELEASE}/deployment.yaml


echo "[----- Setting up MetalLB ----]"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB-RELEASE}/config/manifests/metallb-native.yaml
