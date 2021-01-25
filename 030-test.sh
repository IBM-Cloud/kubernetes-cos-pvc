#!/bin/bash
set -e
set -o pipefail

function ingressHostName(){
  local basename=$1
  kubectl get ingress/$basename '--output=jsonpath={.spec.tls[0].hosts[0]}'
}
function basename() {
  echo $(cd terraform;terraform output -raw basename)
}

basename=$(basename)
ingress_subdomain=$(ingressHostName $basename)
nginx_subdomain=nginx.$ingress_subdomain
echo Testing nginx ingress: https://$nginx_subdomain
curlOutput=$(curl https://$nginx_subdomain)
if echo "$curlOutput" | grep Success > /dev/null; then
  echo Success
else
  echo "$curlOutput"
  echo
  echo '***' expected results not found instead got the stuff above
fi

# manually test these
if kubectl get deployment | grep jekyllblog; then
  echo open jekyllblog.$ingress_subdomain
fi
if kubectl get deployment | grep jekyllnginx; then
  echo open jekyllnginx.$ingress_subdomain
fi
