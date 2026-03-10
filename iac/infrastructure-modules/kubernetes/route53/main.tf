data "kubernetes_ingress_v1" "default" {
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


data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "default" {
  count = var.static_record ? 0 : 1
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.name
  type    = var.type
  ttl     = var.ttl
  records = [data.kubernetes_ingress_v1.default.status.0.load_balancer.0.ingress.0.hostname]
}

resource "aws_route53_record" "static_record" {
  count = var.static_record ? 1 : 0
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.name
  type    = var.type
  ttl     = var.ttl
  records = [var.domain_record]
}