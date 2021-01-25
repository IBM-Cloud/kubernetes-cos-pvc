#!/bin/bash

source $(dirname "$0")/names.sh

(
  cd terraform
  terraform destroy -auto-approve
)


if [ $IBMCR = "true" ]; then
  ibmcloud cr namespace-rm $CR_NAMESPACE
fi
