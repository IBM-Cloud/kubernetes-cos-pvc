#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh
echo $IMAGE_FQN_NGINX - image

echo '>>> ibmcloud required, setting apipkey, resource group and region'
ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -g $RESOURCE_GROUP -r $REGION
ibmcloud cr login

# expecting ks plugin installed
ibmcloud ks help > /dev/null

echo '>>> jq required'
jq --version

echo '>>> kubectl required'
kubectl version --client=true

echo '>>> Prerequisites met'
