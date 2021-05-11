#!/bin/bash

source $(dirname "$0")/names.sh

echo '>>>' terraform destroy resources
(
  cd terraform
  terraform destroy -auto-approve
)

echo '>>>' terraform destroy kubernetes cluster
(
  cd cluster
  if [ -e terraform.tfstate ]; then
    terraform destroy -auto-approve
  fi
)


if [ $IBMCR = "true" ]; then
  ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -g $RESOURCE_GROUP -r $REGION
  echo '>>> remove container regisgtry namespace'
  ibmcloud cr namespace-rm $CR_NAMESPACE --force
fi
