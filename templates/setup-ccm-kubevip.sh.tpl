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
      "loadbalancer": "kube-vip://"
    }
EOF

kubectl apply -f equinix-secret-config.yaml

kubectl apply -f https://github.com/equinix/cloud-provider-equinix-metal/releases/download/${CCM-RELEASE}/deployment.yaml


echo "[----- Setting up Kube-VIP ----]"

kubectl apply -f https://kube-vip.io/manifests/rbac.yaml

alias kube-vip="docker run --network host --rm plndr/kube-vip:${KUBE-VIP-RELEASE}"

kube-vip manifest daemonset   --interface lo   --services   --bgp   --annotations metal.equinix.com   --inCluster | kubectl apply -f -
