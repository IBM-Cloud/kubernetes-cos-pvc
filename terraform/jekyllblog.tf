locals {
  jekyllblog_pvc_name = "${var.basename}-jekyllblog"
}
resource "kubernetes_persistent_volume_claim" "jekyllblog" {
  metadata {
    name = local.jekyllblog_pvc_name
    annotations = {
      "ibm.io/auto-create-bucket" : "true"
      "ibm.io/auto-delete-bucket" : "false"
      "ibm.io/auto_cache" : "true"
      # "ibm.io/bucket" : "${var.basename}-jekyllblog"
      "ibm.io/secret-name" : kubernetes_secret.cos.metadata[0].name
      "ibm.io/set-access-policy" : "false"
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

resource "kubernetes_deployment" "jekyllblog" {
  metadata {
    name = "${var.basename}jekyllblog-deployment"
    labels = {
      app = "${var.basename}jekyllblog"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.basename}jekyllblog"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.basename}jekyllblog"
        }
      }

      spec {
        container {
          name    = "jekyllblog"
          image   = var.imagefqn_jekyll
          command = ["sh", "-c", "git clone https://github.com/IBM-Cloud/kubernetes-cos-pvc.git; cd kubernetes-cos-pvc/example/jekyllblog/myblog; mkdir _site; jekyll serve"]
          port {
            container_port = "4000"
          }
          volume_mount {
            name       = "volname"
            mount_path = "/srv/jekyll"
          }
        }
        volume {
          name = "volname"
          persistent_volume_claim {
            claim_name = local.jekyllblog_pvc_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jekyllblog" {
  metadata {
    name = "${var.basename}jekyllblog-service"
    labels = {
      app = "${var.basename}jekyllblog"
    }
  }
  spec {
    port {
      port = 4000
    }
    selector = {
      app = "${var.basename}jekyllblog"
    }
  }
}
