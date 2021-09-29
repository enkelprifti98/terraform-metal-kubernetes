#!/bin/bash
ROOK_CEPH_CLUSTER_STATE="$(kubectl -n rook-ceph get CephCluster -o json | jq -r .items[0].status.state)"
until [ ${ROOK_CEPH_CLUSTER_STATE} == "Created" ]
do
  echo "Waiting for the rook-ceph cluster to be created ..."
  sleep 5
  ROOK_CEPH_CLUSTER_STATE="$(kubectl -n rook-ceph get CephCluster -o json | jq -r .items[0].status.state)"
done
echo "Rook-Ceph cluster has been created!"
