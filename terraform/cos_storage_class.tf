resource null_resource cos_storage_class {
  depends_on = [helm_release.ibm_helm] # comment this out and all the stuff below to avoid installing cos storage class
}

### comment all of the stuff below if cos storage class is alredy installed in your cluster


# Install the cos storage class into the cluster.
# This has the side effect of initializaing the kubectl command for the cluster

provider "helm" {
  kubernetes {
    config_path = data.ibm_container_cluster_config.cluster.config_file_path
  }
}

locals {
  # return a json string with values, including datacenter:
  # {
  #   ...
  #   "datacenter": "dal10",
  # }
  bash_command = <<-EOS
    ibmcloud ks cluster config --cluster ${var.cluster_name} > /dev/null 2>&1
    kubectl get cm cluster-info -n kube-system -o jsonpath='{.data.cluster-config\.json}'
  EOS
}

data "external" "cluster_info" {
  program = ["bash", "-c", local.bash_command]
}

locals {
  dcname = data.external.cluster_info.result["datacenter"]
}

resource "helm_release" "ibm_helm" {
  name = "ibm-helm"
  repository = "https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm"
  chart      = "ibm-object-storage-plugin"
  set {
    name  = "dcname"
    value = local.dcname
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
