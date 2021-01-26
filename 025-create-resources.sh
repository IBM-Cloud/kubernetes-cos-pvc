#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh

echo '>>>' terraform build all resources
(
  cd terraform
  cat > terraform.tfvars <<EOF
  resource_group = "$RESOURCE_GROUP"
  region = "$REGION"
  basename = "$BASENAME"
  cluster_name = "$CLUSTER_NAME"
  imagefqn_nginx = "$IMAGE_FQN_NGINX"
  imagefqn_jekyll = "$IMAGE_FQN_JEKYLL"
EOF
  terraform init
  terraform apply -auto-approve
)
