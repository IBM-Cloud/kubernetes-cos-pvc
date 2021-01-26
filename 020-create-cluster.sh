#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh

echo '>>>' terraform create cluster
(
  cd cluster
  cat > terraform.tfvars <<EOF
  resource_group = "$RESOURCE_GROUP"
  region = "$REGION"
  basename = "$BASENAME"
  cluster_name = "$CLUSTER_NAME"
EOF
  terraform init
  terraform apply -auto-approve
)
