#!/bin/bash
set -e
set -o pipefail

if ! [ $IBMCR = "true" ]; then
  echo skipping ibm container registry because environment variable IBMCR not true
  exit 0
fi

# include common names
source $(dirname "$0")/names.sh

echo '>>> ibmcloud cr login, might be required, skipping for now'
# ibmcloud cr login

echo '>>> create container regisgtry namespace'
if ! ibmcloud cr namespace-add $CR_NAMESPACE; then
  echo assuming namespace already exists
fi

echo '>>>' pull/push image $IMAGE_NGINX
echo docker pull push $IMAGE_FQN_NGINX
docker pull $IMAGE_NGINX
docker tag $IMAGE_NGINX $IMAGE_FQN_NGINX
docker push $IMAGE_FQN_NGINX
ibmcloud cr images

echo '>>>' pull/push image $IMAGE_JEKYLL
echo docker pull push $IMAGE_FQN_JEKYLL
docker pull $IMAGE_JEKYLL
docker tag $IMAGE_JEKYLL $IMAGE_FQN_JEKYLL
docker push $IMAGE_FQN_JEKYLL
ibmcloud cr images
