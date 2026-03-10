data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}


resource "kubernetes_service_account" "service_account" {
  metadata {
    name = var.service_account_name
  }
}

resource "kubernetes_secret" "service_account_token" {
  metadata {
    name = "${var.service_account_name}-token"
    annotations = {
      "kubernetes.io/service-account.name" = var.service_account_name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "service_role" {
  metadata {
    name      = var.role_name
    #namespace = var.namespace
  }

  dynamic "rule" {
    for_each = var.role_rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_role_binding" "service_role_binding" {
  for_each                 = toset(var.allow_namespace)
  metadata {
    name      = var.role_binding_name
    namespace = each.value 
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = var.role_name
    api_group = "rbac.authorization.k8s.io"
  }
}


# resource "kubernetes_cluster_role_binding" "service_cluster_role_binding" {
#   for_each                 = toset(var.allow_namespace)
#   metadata {
#     name =  var.role_binding_name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = var.service_account_name
#     namespace = var.namespace
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = var.service_account_name
#     namespace = var.namespace
#   }

#   role_ref {
#     kind     = "ClusterRole"
#     name     = var.role_name
#     api_group = "rbac.authorization.k8s.io"
#   }
# }

resource "local_file" "kubeconfig" {
  count    = var.generate_kubeconfig_file ? 1 : 0
  content  = templatefile("${path.module}/kubeconfig.tftpl", { server = var.cluster_endpoint, service_account = var.service_account_name, namespace = var.namespace, cluster_ca_data = base64encode(kubernetes_secret.service_account_token.data["ca.crt"]), cluster_name = "default-cluster", context = "default", token = kubernetes_secret.service_account_token.data["token"] })
  filename = var.filename
}