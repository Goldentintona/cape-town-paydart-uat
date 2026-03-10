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

# resource "kubernetes_secret" "secret_registry" {

#   metadata {
#     name      = var.kubernetes_secret
#     namespace = var.namespace
#   }

#     data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "${var.registry_server}" = {
#           "username" = var.docker_username,
#           "password" = var.docker_password,
#           "email"    = var.docker_email
#           "auth"     = base64encode("${var.docker_username}:${var.docker_password}")
#         }
#       }
#     })
#   }
#   type = "kubernetes.io/dockerconfigjson"
# }

resource "kubernetes_secret" "docker_registry" {
  for_each = toset(var.namespaces)

  metadata {
    name      = var.name
    namespace = each.key
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.docker_username,
          "password" = var.docker_password,
          "email"    = var.docker_email
          "auth"     = base64encode("${var.docker_username}:${var.docker_password}")
        }
      }
    })
  }
}