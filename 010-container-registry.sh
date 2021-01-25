#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh

[ x$IMAGE == x ] && exit 1


ibmcloud cr login

if ! ibmcloud cr namespace-add $CR_NAMESPACE; then
  echo assuming namespace already exists
fi

echo docker pull push $IMAGE_FQN
docker pull $IMAGE
docker tag $IMAGE $IMAGE_FQN
docker push $IMAGE_FQN
ibmcloud cr images
