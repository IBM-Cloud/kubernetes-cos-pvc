variable dcname {}

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
