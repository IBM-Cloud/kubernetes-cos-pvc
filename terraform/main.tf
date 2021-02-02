data "ibm_resource_group" "group" {
  name = var.resource_group
}
data "ibm_container_vpc_cluster" "cluster" {
  name  = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}
data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = var.cluster_name
  admin = true
}

# ----------------------
# a cloud object storage, COS, resource and two keys (service credentials): manager and writer
resource "ibm_resource_instance" "objectstorage" {
  name              = var.cloudobjectstorage_name
  service           = "cloud-object-storage"
  plan              = var.cloudobjectstorage_plan
  location          = var.cloudobjectstorage_location
  resource_group_id = data.ibm_resource_group.group.id
}

resource "ibm_resource_key" "cos_manager" {
  name                 = "${var.basename}-cos-hmac-secret-manager"
  role                 = "Manager"
  resource_instance_id = ibm_resource_instance.objectstorage.id
  parameters = {
    HMAC : true
  }
}

resource "ibm_resource_key" "cos_writer" {
  name                 = "${var.basename}-cos-hmac-secret-writer"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.objectstorage.id
  parameters = {
    HMAC : true
  }
}

# ----------------------
provider "kubernetes" {
  load_config_file = true
  config_path      = data.ibm_container_cluster_config.cluster.config_file_path
}

resource "kubernetes_secret" "cos" {
  type = "ibm/ibmc-s3fs"
  metadata {
    name = var.basename
  }

  data = {
    access-key      = ibm_resource_key.cos_writer.credentials["cos_hmac_keys.access_key_id"]
    secret-key      = ibm_resource_key.cos_writer.credentials["cos_hmac_keys.secret_access_key"]
    res-conf-apikey = ibm_resource_key.cos_manager.credentials.apikey
  }
}

locals {
  pvc_nginx_claim_name = var.basename
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  depends_on = [null_resource.cos_storage_class]
  metadata {
    name = local.pvc_nginx_claim_name
    annotations = {
      "ibm.io/auto-create-bucket" : "true"
      "ibm.io/auto-delete-bucket" : "false"
      "ibm.io/auto_cache" : "true"
      "ibm.io/bucket" : var.bucket_name
      "ibm.io/secret-name" : kubernetes_secret.cos.metadata[0].name
      "ibm.io/set-access-policy" : "true"
    }
  }
  spec {
    storage_class_name = "ibmc-s3fs-standard-regional"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "${var.basename}nginx-deployment"
    labels = {
      app = "${var.basename}nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.basename}nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.basename}nginx"
        }
      }

      spec {
        container {
          name    = "nginx"
          image   = var.imagefqn_nginx
          command = ["sh", "-c", "echo '#Success' > /usr/share/nginx/html/index.html ; exec nginx -g 'daemon off;'"]
          port {
            container_port = "80"
          }
          volume_mount {
            name       = "volname"
            mount_path = "/usr/share/nginx/html"
          }
        }
        volume {
          name = "volname"
          persistent_volume_claim {
            claim_name = local.pvc_nginx_claim_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "${var.basename}nginx-service"
    labels = {
      app = "${var.basename}nginx"
    }
  }
  spec {
    port {
      port = 80
    }
    selector = {
      app = "${var.basename}nginx"
    }
  }
}

resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = var.basename
    annotations = {
      "kubernetes.io/ingress.class" : "public-iks-k8s-nginx"
    }
  }

  spec {
    tls {
      secret_name = data.ibm_container_vpc_cluster.cluster.ingress_secret
      hosts       = [data.ibm_container_vpc_cluster.cluster.ingress_hostname]
    }
    rule {
      host = "nginx.${data.ibm_container_vpc_cluster.cluster.ingress_hostname}"
      http {
        path {
          backend {
            service_name = kubernetes_service.nginx.metadata[0].name
            service_port = 80
          }
        }
      }
    }
    rule {
      host = "jekyllblog.${data.ibm_container_vpc_cluster.cluster.ingress_hostname}"
      http {
        path {
          backend {
            service_name = kubernetes_service.jekyllblog.metadata[0].name
            service_port = 4000
          }
        }
      }
    }
    rule {
      host = "jekyllnginx.${data.ibm_container_vpc_cluster.cluster.ingress_hostname}"
      http {
        path {
          backend {
            service_name = kubernetes_service.jekyllnginx.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}

# ----------------------
output cluster_name {
  value = data.ibm_container_vpc_cluster.cluster.name
}
output cluster_id {
  value = data.ibm_container_vpc_cluster.cluster.id
}
output basename {
  value = var.basename
}
output bucket_pv {
  value = kubernetes_persistent_volume_claim.pvc.spec[0].volume_name
}

