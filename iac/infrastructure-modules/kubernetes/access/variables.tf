variable "cluster_name" {
  type        = string
  default     = ""
  description = "(Required) Name of the cluster"
}

variable "service_account_name" {
  description = "Name of the ServiceAccount"
  type        = string
}

variable "role_name" {
  description = "Name of the Role"
  type        = string
}

variable "role_binding_name" {
  description = "Name of the RoleBinding"
  type        = string
}

variable "role_rules" {
  description = "List of rules for the Role"
  type = list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
  default = []
}

variable "cluster_endpoint" {
  description = "Kubernetes API server URL"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "generate_kubeconfig_file" {
  description = "If true, a local kubeconfig will be generated. If false, it generates only the output"
  type        = bool
  default     = false
}

variable "filename" {
  description = "Output file name and path. Must only be set if `generate_kubeconfig_file` is set to `true`."
  type        = string
  default     = "kubeconfig"
}

variable "allow_namespace" {
  type    = list(string)
  default = ["default"]
}