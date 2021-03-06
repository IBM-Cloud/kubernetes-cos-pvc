resource "kubernetes_deployment" "jekyllnginx" {
  metadata {
    name = "${var.basename}jekyllnginx-deployment"
    labels = {
      app = "${var.basename}jekyllnginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.basename}jekyllnginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.basename}jekyllnginx"
        }
      }

      spec {
        container {
          name    = "jekyllnginx"
          image   = var.imagefqn_nginx
          command = ["sh", "-c", "cd /usr/share/nginx; rm -rf html; ln -s /blog/kubernetes-cos-pvc/example/jekyllblog/myblog/_site html; exec nginx -g 'daemon off;'"]
          port {
            container_port = "80"
          }
          volume_mount {
            name       = "volname"
            mount_path = "/blog"
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

resource "kubernetes_service" "jekyllnginx" {
  metadata {
    name = "${var.basename}jekyllnginx-service"
    labels = {
      app = "${var.basename}jekyllnginx"
    }
  }
  spec {
    port {
      port = 80
    }
    selector = {
      app = "${var.basename}jekyllnginx"
    }
  }
}
