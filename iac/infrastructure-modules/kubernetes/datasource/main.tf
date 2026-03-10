variable "ingress_name" {
  description = "The name of the Kubernetes Ingress resource (optional)."
  type        = string
  default     = ""  # Default to empty if not provided
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

data "kubernetes_ingress_v1" "default" {
  count = var.ingress_name != "" ? 1 : 0

  metadata {
    name = var.ingress_name
  }
}
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

output "ingress_details" {
  description = "Details of the Kubernetes Ingress, if provided"
  value       = length(data.kubernetes_ingress_v1.default) > 0 ? data.kubernetes_ingress_v1.default[0] : null
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = data.aws_eks_cluster.default.endpoint
}

# ingress_name = "your-ingress-name"
# cluster_name = "your-cluster-name"