resource null_resource cos_storage_class {
  depends_on = [helm_release.ibm_helm] # comment this out and all the stuff below to avoid installing cos storage class
}

### comment all of the stuff below if cos storage class is alredy installed in your cluster ###


# Install the cos storage class into the cluster.

provider "helm" {
  kubernetes {
    config_path = data.ibm_container_cluster_config.cluster.config_file_path
  }
}

resource "helm_release" "ibm_helm" {
  name = "ibm-helm"
  repository = "https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm"
  chart      = "ibm-object-storage-plugin"
  set {
    name  = "dcname"
    value = var.dcname
  }
  set {
    name  = "bucketAccessPolicy"
    value = "true"
  }
  set {
    name  = "provider"
    value = "IBMC-VPC"
  }
  set {
    name  = "workerOS"
    value = "debian"
  }
  set {
    name  = "platform"
    value = "k8s"
  }
  set {
    name  = "kubeDriver"
    value = "/usr/libexec/kubernetes"
  }
  set {
    name  = "license"
    value = "true"
  }
}
