resource "kubernetes_namespace" "this" {
  count = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? 1 : 0
  metadata {
    name = var.namespace
  }
}

data "kubernetes_namespace" "this" {
  count = !var.create_namespace || contains(local.default_namespaces, var.namespace) ? 1 : 0
  metadata {
    name = var.namespace
  }
}

locals {
  default_namespaces = ["default", "kube-system"]
}


resource "kubernetes_service_account" "cert_manager_cainjector" {
  metadata {
    name      = "${var.name}-cainjector"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "cainjector"

      "app.kubernetes.io/component" = "cainjector"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "cainjector"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_service_account" "cert_manager" {
  metadata {
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_service_account" "cert_manager_webhook" {
  metadata {
    name      = "${var.name}-webhook"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "cert_manager_cainjector" {
  metadata {
    name = "${var.name}-cainjector"

    labels = {
      app = "cainjector"

      "app.kubernetes.io/component" = "cainjector"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "cainjector"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["get", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations", "mutatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = ["apiregistration.k8s.io"]
    resources  = ["apiservices"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = ["auditregistration.k8s.io"]
    resources  = ["auditsinks"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_issuers" {
  metadata {
    name = "${var.name}-controller-issuers"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["update"]
    api_groups = ["${var.api_group}"]
    resources  = ["issuers", "issuers/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["issuers"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_clusterissuers" {
  metadata {
    name = "${var.name}-controller-clusterissuers"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["update"]
    api_groups = ["${var.api_group}"]
    resources  = ["clusterissuers", "clusterissuers/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["clusterissuers"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_certificates" {
  metadata {
    name = "${var.name}-controller-certificates"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["update"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates", "certificates/status", "certificaterequests", "certificaterequests/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates", "certificaterequests", "clusterissuers", "issuers"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates/finalizers", "certificaterequests/finalizers"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "watch"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["orders"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_orders" {
  metadata {
    name = "${var.name}-controller-orders"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["update"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["orders", "orders/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["orders", "challenges"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["clusterissuers", "issuers"]
  }

  rule {
    verbs      = ["create", "delete"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["challenges"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["orders/finalizers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_challenges" {
  metadata {
    name = "${var.name}-controller-challenges"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["update"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["challenges", "challenges/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["challenges"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["issuers", "clusterissuers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete"]
    api_groups = [""]
    resources  = ["pods", "services"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "update"]
    api_groups = ["networking.x-k8s.io"]
    resources  = ["httproutes"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["route.openshift.io"]
    resources  = ["routes/custom-host"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["challenges/finalizers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_ingress_shim" {
  metadata {
    name = "${var.name}-controller-ingress-shim"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["create", "update", "delete"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates", "certificaterequests"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates", "certificaterequests", "issuers", "clusterissuers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/finalizers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.x-k8s.io"]
    resources  = ["gateways", "httproutes"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.x-k8s.io"]
    resources  = ["gateways/finalizers", "httproutes/finalizers"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_view" {
  metadata {
    name = "${var.name}-view"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version

      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"

      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"

      "rbac.authorization.k8s.io/aggregate-to-view" = "true"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates", "certificaterequests", "issuers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["challenges", "orders"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_edit" {
  metadata {
    name = "${var.name}-edit"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version

      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"

      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
    }
  }

  rule {
    verbs      = ["create", "delete", "deletecollection", "patch", "update"]
    api_groups = ["${var.api_group}"]
    resources  = ["certificates", "certificaterequests", "issuers"]
  }

  rule {
    verbs      = ["create", "delete", "deletecollection", "patch", "update"]
    api_groups = ["acme.${var.api_group}"]
    resources  = ["challenges", "orders"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_approve_cert_manager_io" {
  metadata {
    name = "${var.name}-controller-approve:cert-manager-io"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = var.name

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs          = ["approve"]
    api_groups     = ["${var.api_group}"]
    resources      = ["signers"]
    resource_names = ["issuers.${var.api_group}/*", "clusterissuers.${var.api_group}/*"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_certificatesigningrequests" {
  metadata {
    name = "${var.name}-controller-certificatesigningrequests"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = var.name

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests/status"]
  }

  rule {
    verbs          = ["sign"]
    api_groups     = ["certificates.k8s.io"]
    resources      = ["signers"]
    resource_names = ["issuers.${var.api_group}/*", "clusterissuers.${var.api_group}/*"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
  }
}

resource "kubernetes_cluster_role" "cert_manager_webhook_subjectaccessreviews" {
  metadata {
    name = "${var.name}-webhook:subjectaccessreviews"

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_cainjector" {
  metadata {
    name = "${var.name}-cainjector"

    labels = {
      app = "cainjector"

      "app.kubernetes.io/component" = "cainjector"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "cainjector"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-cainjector"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-cainjector"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_issuers" {
  metadata {
    name = "${var.name}-controller-issuers"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-issuers"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_clusterissuers" {
  metadata {
    name = "${var.name}-controller-clusterissuers"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-clusterissuers"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_certificates" {
  metadata {
    name = "${var.name}-controller-certificates"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-certificates"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_orders" {
  metadata {
    name = "${var.name}-controller-orders"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-orders"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_challenges" {
  metadata {
    name = "${var.name}-controller-challenges"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-challenges"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_ingress_shim" {
  metadata {
    name = "${var.name}-controller-ingress-shim"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-ingress-shim"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_approve_cert_manager_io" {
  metadata {
    name = "${var.name}-controller-approve:cert-manager-io"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = var.name

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-approve:cert-manager-io"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_certificatesigningrequests" {
  metadata {
    name = "${var.name}-controller-certificatesigningrequests"

    labels = {
      app = var.name

      "app.kubernetes.io/component" = var.name

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-controller-certificatesigningrequests"
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_webhook_subjectaccessreviews" {
  metadata {
    name = "${var.name}-webhook:subjectaccessreviews"

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-webhook"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name}-webhook:subjectaccessreviews"
  }
}

resource "kubernetes_role" "cert_manager_cainjector_leaderelection" {
  metadata {
    name      = "${var.name}-cainjector:leaderelection"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "cainjector"

      "app.kubernetes.io/component" = "cainjector"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "cainjector"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs          = ["get", "update", "patch"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["${var.name}-cainjector-leader-election", "${var.name}-cainjector-leader-election-core"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs          = ["get", "update", "patch"]
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["${var.name}-cainjector-leader-election", "${var.name}-cainjector-leader-election-core"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_role" "cert_manager_leaderelection" {
  metadata {
    name      = "${var.name}:leaderelection"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs          = ["get", "update", "patch"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["${var.name}-controller"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs          = ["get", "update", "patch"]
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["${var.name}-controller"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_role" "cert_manager_webhook_dynamic_serving" {
  metadata {
    name      = "${var.name}-webhook:dynamic-serving"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  rule {
    verbs          = ["get", "list", "watch", "update"]
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["${var.name}-webhook-ca"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

resource "kubernetes_role_binding" "cert_manager_cainjector_leaderelection" {
  metadata {
    name      = "${var.name}-cainjector:leaderelection"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "cainjector"

      "app.kubernetes.io/component" = "cainjector"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "cainjector"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-cainjector"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${var.name}-cainjector:leaderelection"
  }
}

resource "kubernetes_role_binding" "cert_manager_leaderelection" {
  metadata {
    name      = "${var.name}:leaderelection"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${var.name}:leaderelection"
  }
}

resource "kubernetes_role_binding" "cert_manager_webhook_dynamic_serving" {
  metadata {
    name      = "${var.name}-webhook:dynamic-serving"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-webhook"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${var.name}-webhook:dynamic-serving"
  }
}

resource "kubernetes_service" "cert_manager" {
  metadata {
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  spec {
    port {
      name        = "tcp-prometheus-servicemonitor"
      protocol    = "TCP"
      port        = 9402
      target_port = "9402"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "cert_manager_webhook" {
  metadata {
    name      = "${var.name}-webhook"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  spec {
    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "10250"
    }

    selector = {
      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "cert_manager_cainjector" {
  metadata {
    name      = "${var.name}-cainjector"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "cainjector"

      "app.kubernetes.io/component" = "cainjector"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "cainjector"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "cainjector"

        "app.kubernetes.io/instance" = var.name

        "app.kubernetes.io/name" = "cainjector"
      }
    }

    template {
      metadata {
        labels = {
          app = "cainjector"

          "app.kubernetes.io/component" = "cainjector"

          "app.kubernetes.io/instance" = var.name

          "app.kubernetes.io/name" = "cainjector"

          "app.kubernetes.io/version" = var.kubernetes_version
        }
      }

      spec {
        container {
          name  = var.name
          image = "quay.io/jetstack/cert-manager-cainjector:v1.6.1"
          args  = ["--v=2", "--leader-election-namespace=kube-system"]

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "${var.name}-cainjector"

        security_context {
          run_as_non_root = true
        }
      }
    }
  }
}

resource "kubernetes_deployment" "cert_manager" {
  metadata {
    name      = var.name
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = var.name

      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = var.name

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"

        "app.kubernetes.io/instance" = var.name

        "app.kubernetes.io/name" = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name

          "app.kubernetes.io/component" = "controller"

          "app.kubernetes.io/instance" = var.name

          "app.kubernetes.io/name" = var.name

          "app.kubernetes.io/version" = var.kubernetes_version
        }

        annotations = {
          "prometheus.io/path" = "/metrics"

          "prometheus.io/port" = "9402"

          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        container {
          name  = var.name
          image = "quay.io/jetstack/cert-manager-controller:v1.6.1"
          args  = ["--v=2", "--cluster-resource-namespace=$(POD_NAMESPACE)", "--leader-election-namespace=kube-system"]

          port {
            container_port = 9402
            protocol       = "TCP"
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = var.name

        security_context {
          run_as_non_root = true
        }
      }
    }
  }
}

resource "kubernetes_deployment" "cert_manager_webhook" {
  metadata {
    name      = "${var.name}-webhook"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "webhook"

        "app.kubernetes.io/instance" = var.name

        "app.kubernetes.io/name" = "webhook"
      }
    }

    template {
      metadata {
        labels = {
          app = "webhook"

          "app.kubernetes.io/component" = "webhook"

          "app.kubernetes.io/instance" = var.name

          "app.kubernetes.io/name" = "webhook"

          "app.kubernetes.io/version" = var.kubernetes_version
        }
      }

      spec {
        container {
          name  = var.name
          image = "quay.io/jetstack/cert-manager-webhook:v1.6.1"
          args  = ["--v=2", "--secure-port=10250", "--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)", "--dynamic-serving-ca-secret-name=cert-manager-webhook-ca", "--dynamic-serving-dns-names=cert-manager-webhook,cert-manager-webhook.cert-manager,cert-manager-webhook.cert-manager.svc"]

          port {
            name           = "https"
            container_port = 10250
            protocol       = "TCP"
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = "6080"
              scheme = "HTTP"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "6080"
              scheme = "HTTP"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 1
            period_seconds        = 5
            success_threshold     = 1
            failure_threshold     = 3
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "${var.name}-webhook"

        security_context {
          run_as_non_root = true
        }
      }
    }
  }
}

resource "kubernetes_mutating_webhook_configuration" "cert_manager_webhook" {
  metadata {
    name = "${var.name}-webhook"

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }

    annotations = {
      "${var.api_group}/inject-ca-from-secret" = "${var.name}/${var.name}-webhook-ca"
    }
  }

  webhook {
    name = "webhook.${var.api_group}"

    client_config {
      service {
        namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
        name      = "${var.name}-webhook"
        path      = "/mutate"
      }
    }

    rule {
      api_groups   = ["${var.api_group}", "acme.${var.api_group}"]
      api_versions = ["v1"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["*/*"]
    }

    failure_policy            = "Fail"
    match_policy              = "Equivalent"
    side_effects              = "None"
    timeout_seconds           = 10
    admission_review_versions = ["v1", "v1beta1"]
  }
}

resource "kubernetes_validating_webhook_configuration" "cert_manager_webhook" {
  metadata {
    name = "${var.name}-webhook"

    labels = {
      app = "webhook"

      "app.kubernetes.io/component" = "webhook"

      "app.kubernetes.io/instance" = var.name

      "app.kubernetes.io/name" = "webhook"

      "app.kubernetes.io/version" = var.kubernetes_version
    }

    annotations = {
      "${var.api_group}/inject-ca-from-secret" = "${var.name}/${var.name}-webhook-ca"
    }
  }

  webhook {
    name = "webhook.${var.api_group}"

    client_config {
      service {
        namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
        name      = "${var.name}-webhook"
        path      = "/validate"
      }
    }

    rule {
      api_groups   = ["${var.api_group}", "acme.${var.api_group}"]
      api_versions = ["v1"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["*/*"]
    }

    failure_policy = "Fail"
    match_policy   = "Equivalent"

    namespace_selector {
      match_expressions {
        key      = "${var.api_group}/disable-validation"
        operator = "NotIn"
        values   = ["true"]
      }

      match_expressions {
        key      = "name"
        operator = "NotIn"
        values   = [var.name]
      }
    }

    side_effects              = "None"
    timeout_seconds           = 10
    admission_review_versions = ["v1", "v1beta1"]
  }
}
