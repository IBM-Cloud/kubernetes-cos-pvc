# Blog Post
Run each of the commands in order

cp teamplate.localvars localvars

000 - prereq check and local.env check


020-container-registry.sh - Container images can come from public registries (hub.docker.com) or from the ibm container registry.  A VPC public gateway is required to connect to a public registry.  The ibm container registry in this example is in the same region as the the kubernetes cluster and accessed over a regional ip address.

030-kubernetes-secret.sh - Create a kubernetes secret



# enhancement more configurable ibm_container_bind_service it needs to support k8s and pvc/cos
- Expected: A way to create a kuberrnetes secret resource with the required parameters from parameters and an ibm_resource_instance
- Actual: not possible

Proposal:

The ibm_container_bind_service` enhancment:

```
resource "ibm_container_bind_service" "bind_objectstorage" {
  ...
  key                 = "${var.basename}-cos-hmac-secret"
  type      = "ibm/ibmc-s3fs"
  mapping   = ?
}
```

- type String Type string like ibm/ibmc-s3fs
- mapping ? mapping from key to secret

Use Case to be resolved:

The k8s service supports a There is Persistent Volume, pv, storage class `ibmc-s3fs-standard-regional`.  A Persistent Volume Claim, pvc, resource can be created that ties ibmc-s3fs-standard-regional to a COS instance and bucket.  To create a directory backed by the bucket the pod mount a volume with the pvc.

Deployment fragment:

```
kind: Deployment
spec:
  selector:
    matchLabels:
      app: ikscos001nginx
  template:
    spec:
      - image: us.icr.io/ikscos001/nginx:latest
      containers:
        volumeMounts:
        - name: volname
          mountPath: /usr/share/nginx/html
      volumes:
      - name: volname
        persistentVolumeClaim:
          claimName: ikscos001nginxcosbucket

```

pvc fagment:

```
kind: PersistentVolumeClaim
metadata:
  annotations:
    ibm.io/auto-create-bucket: "true"
    ibm.io/secret-name: "cos-write-access"
spec:
  storageClassName: ibmc-s3fs-standard-regional
```

The cos-write-access kubernetes secret contains two keys:

$ kc describe secret/cos-write-access
```
Type:  ibm/ibmc-s3fs
Data
====
access-key:  32 bytes
secret-key:  48 bytes
```

In the COS console ui they are part of a service credential configured with an advanced option { "HMAC": true }. In the cli the same object is called a service instance's service key:

```
$ ibmcloud resource service-key-create cos-write-access --instance-name objectstorage --parameters '{ "HMAC": true }' -g default
Credentials:
               apikey:                   YxYFD-CyadayadayadawEFfmm5kpqlyarO6WpiDzL1tQ
               cos_hmac_keys:
```

Thee `access_key_id` and `secret_access_key` are the values needed in this command:

```
$ kubectl create secret generic cos-write-access --type=ibm/ibmc-s3fs --from-literal=access-key=yadaaccessda405695dyadayadayadaf --from-literal=secret-key=yadasecretdaa91e95b2e09401d5e23de8fyadayadayada3

It is not possible to make this secret key using terraform.  here is what I've tried:

```
# bind the cloud object storage service to the cluster
resource "ibm_container_bind_service" "bind_objectstorage" {
  cluster_name_id = ibm_container_vpc_cluster.cluster.id
  service_instance_id = ibm_resource_instance.objectstorage.guid
  namespace_id        = "default"
  resource_group_id   = data.resource_group.group.id
  role = "Writer"
}
```

This both creates the credential and creates the kubernetes secret.  But it is missing:
- parameter - can not specify '{ "HMAC": true }' in the cos service credentials
- type - can not specify kubrernetes secret: Type:  ibm/ibmc-s3fs
- keys - the kubrernetes secret keys: `access-key` and `secret-key` can not be created.

It is possible to explictly create the service key:

```
resource "ibm_resource_key" "objectstorage" {
  name                 = "${var.basename}-cos-hmac-secret"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.objectstorage.id

  parameters = {
     HMAC: true
  }
}

resource "ibm_container_bind_service" "bind_objectstorage" {
  ...
  key                 = "${var.basename}-cos-hmac-secret"
}
```

This fixes the parameter problem.


Notes
```
CLUSTER_NAME=ikscos001-cluster
ks cluster config --cluster $CLUSTER_NAME

COS_SERVICE_NAME=objectstorage
COS_GUID=$(ibmcloud resource service-instance $COS_SERVICE_NAME  --output json | jq -r '.[]|.guid')
echo $COS_GUID


# Create a secret for HMAC credentials
kubectl config set-context --current --namespace=default
kubectl config view --minify | grep namespace:
kubectl create secret generic cos-write-access --type=ibm/ibmc-s3fs --from-literal=access-key=6ec5dfc019dc4f80a32bc3535e203902 --from-literal=secret-key=c6d52c09ad422f8d337f49336e9860cb81525b16c96f9ef2
kubectl get secret
kubectl describe secret/cos-write-access

# installing the IBM cos plug-in
ibmcloud ks worker ls --cluster $CLUSTER_NAME
helm version
# v3.4.2

#helm repo add iks-charts https://private.icr.io/helm/iks-charts
helm repo add iks-charts https://icr.io/helm/iks-charts
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable
helm repo add ibm-community https://raw.githubusercontent.com/IBM/charts/master/repo/community
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm

helm repo update

helm search repo iks-charts
helm search repo ibm-charts
helm search repo ibm-community
helm search repo entitled
helm search repo ibm-helm

helm fetch --untar ibm-helm/ibm-object-storage-plugin
# If the output shows the error Error: fork/exec /home/iksadmin/.helm/plugins/helm-ibmc/ibmc.sh: permission denied, run chmod 755 /Users/<user_name>/Library/helm/plugins/helm-ibmc/ibmc.sh. Then, rerun helm ibmc --help.

helm plugin install ./ibm-object-storage-plugin/helm-ibmc
helm ibmc --help

mvim ibm-object-storage-plugin/templates/provisioner-sa.yaml
# look for:
# kind: ClusterRole
# apiVersion: rbac.authorization.k8s.io/v1
# metadata:
#   name: ibmcloud-object-storage-secret-reader
# ...
#   #resourceNames: [""]
# 
#   resourceNames: ["cos-write-access"]

helm ibmc install ibm-object-storage-plugin ibm-helm/ibm-object-storage-plugin --set license=true

#check
kubectl get pod --all-namespaces -o wide | grep object
kubectl get storageclass | grep s3

# remove ibm helm plugin
kubectl get storageclass | grep s3
kubectl get pod --all-namespaces | grep object-storage
helm uninstall ibm-object-storage-plugin
kubectl get storageclass | grep s3
kubectl get pod --all-namespaces | grep object-storage

helm plugin list
helm plugin uninstall ibmc
helm plugin list



# create pvc
mvim pvc.yaml

# check pvc.yaml storage clsss configuration. ibm.io/object-store-endpoint=https://s3.direct.us-south.cloud-object-storage.appdomain.cloud
kubectl describe storageclass/ibmc-s3fs-standard-regional

kubectl apply -f pvc.yaml
kubectl get pvc
kubectl describe pvc/ikscos001nginxcosbucket

# create deployment
mvim deployment.yaml
kubectl apply -f deployment.yaml
kubectl describe deployment/ikscos001nginx-deployment
kubectl exec ikscos001nginx-deployment-74b8d4b6f4-dj9k7 -it bash

# to deploy from hub.docker.io a public gateway is required.  terraform/main.tf

```
Open switches:
```
unify naming
terraform/ cos name does not use basename
terraform/terraform.tfvars should be derived from the variables in the parent
terragorm/terraform.tfvars basename should be basename

Note: VPC Gen 2 clusters To enable authorized IPs on VPC Gen 2, set the --set bucketAccessPolicy=true flag.
Adding your IBM Cloud Object Storage credentials to the default storage classes
  If you add your IBM Cloud Object Storage credentials to the default storage classes, you do not need to refer to your secret in the PVC.
VPC: Setting up authorized IP addresses for IBM Cloud Object Storage
deployment.yal
  securityContext:
    runAsUser: <non_root_user>
```


output of helm ibmc install command

```
➜  ikscospvc_2336 git:(master) ✗ helm ibmc install ibm-object-storage-plugin ibm-helm/ibm-object-storage-plugin --set license=true

Helm version: v3.4.2+g23dd3af
Installing the Helm chart...
PROVIDER: IBMC-VPC
WORKER_OS: debian
PLATFORM: k8s
KUBE_DRIVER_PATH: /usr/libexec/kubernetes
CONFIG_BUCKET_ACCESS_POLICY: false
Chart: ibm-helm/ibm-object-storage-plugin
NAME: ibm-object-storage-plugin
LAST DEPLOYED: Wed Jan 13 17:12:26 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing: ibm-object-storage-plugin.   Your release is named: ibm-object-storage-plugin

1. Verify that the storage classes are created successfully:

   $ kubectl get storageclass | grep 'ibmc-s3fs'

2. Verify that plugin pods are in "Running" state:

   $ kubectl get pods -n kube-system -o wide | grep object

   The installation is successful when you see one `ibmcloud-object-storage-plugin` pod and one or more `ibmcloud-object-storage-driver` pods.
   The number of `ibmcloud-object-storage-driver` pods equals the number of worker nodes in your cluster. All pods must be in a `Running` state
   for the plug-in to function properly. If the pods fail, run `kubectl describe pod -n kube-system <pod_name>`
   to find the root cause for the failure.
######################################################
Additional steps for IBM Kubernetes Service(IKS) only:
######################################################

  1. If the plugin pods show an "ErrImagePull" or "ImagePullBackOff" error, verify that the image pull secrets to access IBM Cloud Container Registry exist in the "kube-system" namespace of your cluster.

     $ kubectl get secrets -n kube-system | grep icr-io

     Example output if the secrets exist:
     ----o/p----
     kube-system-icr-io
     kube-system-us-icr-io
     kube-system-uk-icr-io
     kube-system-de-icr-io
     kube-system-au-icr-io
     kube-system-jp-icr-io
     ----end----

  2. If the secrets do not exist in the "kube-system" namespace, check if the secrets are available in the "default" namespace of your cluster.

     $ kubectl get secrets -n default | grep icr-io

  3. If the secrets are available in the "default" namespace, copy the secrets to the "kube-system" namespace of your cluster. If the secrets are not available, continue with the next step.

     $ kubectl get secret -n default default-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-us-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-uk-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-de-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-au-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-jp-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -

  4. If the secrets are not available in the "default" namespace, you might have an older cluster and must generate the secrets in the "default" namespace.

     i.  Generate the secrets in the "default" namespace.

         $ ibmcloud ks cluster-pull-secret-apply

     ii. Verify that the secrets are created in the "default" namespace. The creation of the secrets might take a few minutes to complete.

         $ kubectl get secrets -n default | grep icr-io

     iii. Run the commands in step 3 to copy the secrets from the "default" namespace to the "kube-system" namespace.

  5. Verify that the image pull secrets are available in the "kube-system" namespace.

     $ kubectl get secrets -n kube-system | grep icr-io

  6. Verify that the state of the plugin pods changes to "Running".

     $ kubectl get pods -n kube-system | grep object
```

ytt
```
docker run --rm -v ${PWD}:/workspace gerritk/ytt -f .
```
