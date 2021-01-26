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
  echo '>>> remove container regisgtry namespace'
  ibmcloud cr namespace-rm $CR_NAMESPACE --force
fi
