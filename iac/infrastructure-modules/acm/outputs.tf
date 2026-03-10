# Module      : ACM CERTIFICATE
# Description : Terraform ACM Certificate module outputs.

output "id" {
  value       = var.import_certificate ? join("", aws_acm_certificate.import-cert.*.id) : join("", aws_acm_certificate.cert.*.id)
  description = "The ID of the Certificate."
}

output "arn" {
  value       = var.import_certificate ? join("", aws_acm_certificate.import-cert.*.arn) : join("", aws_acm_certificate.cert.*.arn)
  description = "The ARN of the Certificate."
}