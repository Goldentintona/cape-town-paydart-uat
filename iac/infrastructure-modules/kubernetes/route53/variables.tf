variable "cluster_name" {
  type        = string
  default     = ""
  description = "(Required) Name of the cluster"
}

variable "ingress_name" {
  type        = string
  default     = "example.com"
  description = "(String) Name of the ingress, must be unique. Cannot be updated"
}

variable "domain_name" {
  type = string
  default     = ""
}

variable "domain_record" {
  type = string
  default     = ""
}

variable "type" {
  type        = string
  default     = ""
  description = "The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. "
}

variable "ttl" {
  type        = string
  default     = ""
  description = "(Required for non-alias records) The TTL of the record."
}

variable "name" {
  type        = string
  default     = ""
  description = "The name of the record."
}


variable "static_record" {
  type        = bool
  default     = false
  description = "Add route53 records via ingress or not"
}
