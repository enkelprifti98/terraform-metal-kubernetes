#!/bin/bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "HOST=\(.host)"')"

if ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i cluster-private-key.pem root@$HOST "test -e $HOME/.kube/config" ; then
    # echo 'File "$HOME/.kube/config" is not there because the kubernetes cluster was not created, aborting.'
    echo '{"command":"failed"}' | jq
else {

# Fetch the join command
CMD=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i cluster-private-key.pem \
    root@$HOST kubeadm token create --ttl 0 --description terraform --print-join-command)

# Produce a JSON object containing the join command
jq -n --arg command "$CMD" '{"command":$command}'

}

fi
