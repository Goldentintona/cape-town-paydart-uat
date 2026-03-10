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

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}


resource "helm_release" "default" {
  name        = var.name
  chart       = var.chart
  description = var.description
  version     = var.chart_version
  set           = local.set_values
  set_sensitive = local.set_sensitive_values

  repository = var.repository
  namespace  = var.kubernetes_namespace


  reset_values = var.reset_values
  reuse_values = var.reuse_values
  timeout      = var.timeout
  values       = var.values
  wait         = var.wait
}

#   dynamic "set" {
#     for_each = var.set
#     content {
#       name  = set.value["name"]
#       value = set.value["value"]
#       type  = set.value["type"]
#     }
#   }

#   dynamic "set_sensitive" {
#     for_each = var.set_sensitive
#     content {
#       name  = set_sensitive.value["name"]
#       value = set_sensitive.value["value"]
#       type  = set_sensitive.value["type"]
#     }
#   }

# }

locals {
  set_values = [
    for s in var.set : {
      name  = s.name
      value = tostring(s.value)
    }
  ]

  set_sensitive_values = [
    for s in var.set_sensitive : {
      name  = s.name
      value = tostring(s.value)
    }
  ]
}