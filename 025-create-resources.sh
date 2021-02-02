#!/bin/bash
set -e
set -o pipefail

# include common names
source $(dirname "$0")/names.sh

echo '>>>' initializing kubectl for the cluster $CLUSTER_NAME
ibmcloud ks cluster config --cluster $CLUSTER_NAME

echo '>>>' retrieving datacenter name, dcname
dcname=$(kubectl get cm cluster-info -n kube-system -o jsonpath='{.data.cluster-config\.json}'| jq -r .datacenter)

echo '>>>' terraform configuration in terraform/terraform.tfvars:
  cat > terraform/terraform.tfvars <<EOF
  resource_group = "$RESOURCE_GROUP"
  region = "$REGION"
  basename = "$BASENAME"
  cluster_name = "$CLUSTER_NAME"
  imagefqn_nginx = "$IMAGE_FQN_NGINX"
  imagefqn_jekyll = "$IMAGE_FQN_JEKYLL"
  dcname = "$dcname"
  cloudobjectstorage_name = "$CLOUDOBJECTSTORAGE_NAME"
  bucket_name = "$BUCKET_NAME"
EOF
cat terraform/terraform.tfvars


echo '>>>' terraform build all resources
(
  cd terraform
  terraform init
  terraform apply -auto-approve
)
