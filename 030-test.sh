function ingressHostName(){
  local basename=$1
  kubectl get ingress/$basename '--output=jsonpath={.spec.tls[0].hosts[0]}'
}
function basename() {
  echo $(cd terraform;terraform output -raw basename)
}

basename=$(basename)
INGRESS_HOST_NAME=$(ingressHostName $basename)/nginx
echo Testing ingress: https://$INGRESS_HOST_NAME
curlOutput=$(curl https://$INGRESS_HOST_NAME)
if echo "$curlOutput" | grep Success > /dev/null; then
  echo Success
else
  echo "$curlOutput"
  echo
  echo '***' expected results not found instead got the stuff above
fi





