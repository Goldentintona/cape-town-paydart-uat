output "kubernetes_ingress" {
  description = "All `kubernetes_ingress` resource attributes."
  value = var.static_record ? "" : data.kubernetes_ingress_v1.default.status.0.load_balancer.0.ingress.0.hostname
}

output "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  value = var.static_record ? aws_route53_record.static_record[0].zone_id : aws_route53_record.default[0].zone_id
}

output "name" {
  description = "The name of the record."
  value = var.static_record ? aws_route53_record.static_record[0].name : aws_route53_record.default[0].name
}

output "type" {
  description = "The record type."
  value = var.static_record ? aws_route53_record.static_record[0].type : aws_route53_record.default[0].type
}

output "ttl" {
  description = "The TTL of the record."
  value = var.static_record ? aws_route53_record.static_record[0].ttl : aws_route53_record.default[0].ttl
}

output "fqdn" {
  description = "FQDN built using the zone domain and name."
  value = var.static_record ? aws_route53_record.static_record[0].fqdn : aws_route53_record.default[0].fqdn
}