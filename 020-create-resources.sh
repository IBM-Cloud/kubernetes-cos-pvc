#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh

(
  cd terraform
  cat > terraform.tfvars <<EOF
  resource_group = "default"
  basename = "ikscos002"
  imagefqn = "$IMAGE_FQN"
EOF
  terraform init
  #terraform apply -auto-approve
  terraform apply
)
