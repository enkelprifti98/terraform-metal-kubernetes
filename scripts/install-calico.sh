#!/bin/bash

# Install Calico
kubectl apply -f https://docs.projectcalico.org/${calico_version}/manifests/calico.yaml

# Download the matching calicoctl version
curl -L  \
	https://github.com/projectcalico/calicoctl/releases/download/${calicoctl_version}/calicoctl \
	-o /usr/local/bin/calicoctl

# Make it executable
chmod +x /usr/local/bin/calicoctl
