#!/bin/bash

# Install Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/${calico_version}/manifests/calico.yaml

# Download the matching calicoctl version
curl -L  \
	https://github.com/projectcalico/calico/releases/download/${calicoctl_version}/calicoctl-linux-amd64 \
	-o /usr/local/bin/calicoctl

# Make it executable
chmod +x /usr/local/bin/calicoctl
