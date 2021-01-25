#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh
echo $IMAGE_FQN - image

ibmcloud target -g $RESOURCE_GROUP
