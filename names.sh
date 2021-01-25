#!/bin/bash
set -e

[ x$BASENAME == x ] && exit 1
case $REGION in
  us-south) CR_REGION=us;;
  *) echo more regions required in case statement; exit 1
esac
# container registry
CR_NAMESPACE=$BASENAME
IMAGE=nginx:latest
IMAGE_FQN=$CR_REGION.icr.io/$CR_NAMESPACE/$IMAGE
INGRESS_NAME=ikscos001; # ingress.yaml

# cluster
CLUSTER_NAME=$BASENAME-cluster
function clusterIngressHostName(){
  ibmcloud ks cluster get --cluster $CLUSTER_NAME --output json | jq -r '.ingress.hostname'
}
