resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = var.name
    }
  }
}

resource "kubernetes_role" "aws_load_balancer_controller_leader_election_role" {
  metadata {
    name      = "aws-load-balancer-controller-leader-election-role"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs          = ["get", "update", "patch"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["aws-load-balancer-controller-leader"]
  }
}

resource "kubernetes_cluster_role" "aws_load_balancer_controller_role" {
  metadata {
    name = "aws-load-balancer-controller-role"

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["endpoints"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["patch", "update"]
    api_groups = [""]
    resources  = ["pods/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["patch", "update"]
    api_groups = [""]
    resources  = ["services/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["elbv2.k8s.aws"]
    resources  = ["ingressclassparams"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["elbv2.k8s.aws"]
    resources  = ["targetgroupbindings"]
  }

  rule {
    verbs      = ["patch", "update"]
    api_groups = ["elbv2.k8s.aws"]
    resources  = ["targetgroupbindings/status"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["patch", "update"]
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["patch", "update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
  }
}

resource "kubernetes_role_binding" "aws_load_balancer_controller_leader_election_rolebinding" {
  metadata {
    name      = "aws-load-balancer-controller-leader-election-rolebinding"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "aws-load-balancer-controller-leader-election-role"
  }
}

resource "kubernetes_cluster_role_binding" "aws_load_balancer_controller_rolebinding" {
  metadata {
    name = "aws-load-balancer-controller-rolebinding"

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "aws-load-balancer-controller-role"
  }
}

resource "kubernetes_service" "aws_load_balancer_webhook_service" {
  metadata {
    name      = "aws-load-balancer-webhook-service"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  spec {
    port {
      port        = 443
      target_port = "9443"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/name" = var.name
    }
  }
}

resource "kubernetes_deployment" "aws_load_balancer_controller" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/name" = var.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"

        "app.kubernetes.io/name" = var.name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"

          "app.kubernetes.io/name" = var.name
        }
      }

      spec {
        volume {
          name = "cert"

          secret {
            secret_name  = "aws-load-balancer-webhook-tls"
            default_mode = "0644"
          }
        }

        container {
          name  = "controller"
          image = "amazon/${var.image_name}:${var.image_version}"
          args  = ["--cluster-name=${var.eks_cluster_name}", "--ingress-class=alb"]

          port {
            name           = "webhook-server"
            container_port = 9443
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "500Mi"
            }

            requests = {
              cpu = "100m"

              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "cert"
            read_only  = true
            mount_path = "/tmp/k8s-webhook-server/serving-certs"
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "61779"
              scheme = "HTTP"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 10
            failure_threshold     = 2
          }

          security_context {
            run_as_non_root           = true
            read_only_root_filesystem = true
          }
        }

        termination_grace_period_seconds = 10
        service_account_name             = var.name

        security_context {
          fs_group = 1337
        }

        priority_class_name = "system-cluster-critical"
      }
    }
  }
}

resource "kubernetes_mutating_webhook_configuration" "aws_load_balancer_webhook" {
  metadata {
    name = "aws-load-balancer-webhook"

    labels = {
      "app.kubernetes.io/name" = var.name
    }

    annotations = {
      "cert-manager.io/inject-ca-from" = "kube-system/aws-load-balancer-serving-cert"
    }
  }

  webhook {
    name = "mpod.elbv2.k8s.aws"

    client_config {
      service {
        namespace = var.namespace
        name      = "aws-load-balancer-webhook-service"
        path      = "/mutate-v1-pod"
      }
    }

    rule {
      operations   = ["CREATE"]
      api_groups   = [""]
      api_versions = ["v1"]
      resources    = ["pods"]
    }

    failure_policy = "Fail"

    namespace_selector {
      match_expressions {
        key      = "elbv2.k8s.aws/pod-readiness-gate-inject"
        operator = "In"
        values   = ["enabled"]
      }
    }

    object_selector {
      match_expressions {
        key      = "app.kubernetes.io/name"
        operator = "NotIn"
        values   = [var.name]
      }
    }

    side_effects              = "None"
    admission_review_versions = ["v1beta1"]
  }

  webhook {
    name = "mtargetgroupbinding.elbv2.k8s.aws"

    client_config {
      service {
        namespace = var.namespace
        name      = "aws-load-balancer-webhook-service"
        path      = "/mutate-elbv2-k8s-aws-v1beta1-targetgroupbinding"
      }
    }

    rule {
      operations   = ["CREATE", "UPDATE"]
      api_groups   = ["elbv2.k8s.aws"]
      api_versions = ["v1beta1"]
      resources    = ["targetgroupbindings"]
    }

    failure_policy            = "Fail"
    side_effects              = "None"
    admission_review_versions = ["v1beta1"]
  }
}

resource "kubernetes_validating_webhook_configuration" "aws_load_balancer_webhook" {
  metadata {
    name = "aws-load-balancer-webhook"

    labels = {
      "app.kubernetes.io/name" = var.name
    }

    annotations = {
      "cert-manager.io/inject-ca-from" = "kube-system/aws-load-balancer-serving-cert"
    }
  }

  webhook {
    name = "vtargetgroupbinding.elbv2.k8s.aws"

    client_config {
      service {
        namespace = var.namespace
        name      = "aws-load-balancer-webhook-service"
        path      = "/validate-elbv2-k8s-aws-v1beta1-targetgroupbinding"
      }
    }

    rule {
      operations   = ["CREATE", "UPDATE"]
      api_groups   = ["elbv2.k8s.aws"]
      api_versions = ["v1beta1"]
      resources    = ["targetgroupbindings"]
    }

    failure_policy            = "Fail"
    side_effects              = "None"
    admission_review_versions = ["v1beta1"]
  }

  webhook {
    name = "vingress.elbv2.k8s.aws"

    client_config {
      service {
        namespace = var.namespace
        name      = "aws-load-balancer-webhook-service"
        path      = "/validate-networking-v1beta1-ingress"
      }
    }

    rule {
      operations   = ["CREATE", "UPDATE"]
      api_groups   = ["networking.k8s.io"]
      api_versions = ["v1beta1"]
      resources    = ["ingresses"]
    }

    failure_policy            = "Fail"
    match_policy              = "Equivalent"
    side_effects              = "None"
    admission_review_versions = ["v1beta1"]
  }
}
