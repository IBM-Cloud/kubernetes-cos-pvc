#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh
echo $IMAGE_FQN_NGINX - image

echo '>>> ibmcloud required, setting resource group'
ibmcloud target -g $RESOURCE_GROUP

# expecting ks plugin installed
ibmcloud ks help > /dev/null

echo '>>> jq required'
jq --version

echo '>>> kubectl required'
kubectl version

