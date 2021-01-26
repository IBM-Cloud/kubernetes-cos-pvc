#!/bin/bash
set -e

[ x$BASENAME == x ] && exit 1
case $REGION in
  us-south) CR_REGION=us;;
  *) echo more regions required in case statement; exit 1
esac

CR_NAMESPACE=$BASENAME

# cluster
function clusterIngressHostName(){
  ibmcloud ks cluster get --cluster $CLUSTER_NAME --output json | jq -r '.ingress.hostname'
}

# nginx
IMAGE_NGINX=nginx:latest
if [ $IBMCR = "true" ]; then
  IMAGE_FQN_NGINX=$CR_REGION.icr.io/$CR_NAMESPACE/$IMAGE_NGINX 
else
  IMAGE_FQN_NGINX="$IMAGE_NGINX"
fi

# jekyll
IMAGE_JEKYLL="jekyll/builder:3.8"
if [ $IBMCR = "true" ]; then
  IMAGE_FQN_JEKYLL=$CR_REGION.icr.io/$CR_NAMESPACE/$IMAGE_JEKYLL
else
  IMAGE_FQN_JEKYLL="$IMAGE_JEKYLL"
fi

