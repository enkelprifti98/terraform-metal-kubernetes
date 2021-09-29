#!/bin/bash

set -x

GATEWAY_PRIVATE_IPV4=($(curl https://metadata.platformequinix.com/metadata | jq -r ".network.addresses[] | select(.public == false) | .gateway"))

BGP_PEERS=$(curl https://metadata.platformequinix.com/metadata | jq -r ".bgp_neighbors[0].peer_ips[]")

for i in $BGP_PEERS; do

ip route add $i via $GATEWAY_PRIVATE_IPV4 dev bond0

done
