#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh

(
  cd terraform
  cat > terraform.tfvars <<EOF
  resource_group = "$RESOURCE_GROUP"
  region = "$REGION"
  basename = "$BASENAME"
  imagefqn_nginx = "$IMAGE_FQN_NGINX"
  imagefqn_jekyll = "$IMAGE_FQN_JEKYLL"
EOF
  terraform init
  terraform apply -auto-approve
)
