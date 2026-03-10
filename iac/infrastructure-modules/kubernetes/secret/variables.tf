variable "cluster_name" {
  type = string
}

variable "name" {
  description = "(Required) Name of the namespace, must be unique. Cannot be updated. For details please see https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names"
  type        = string
}

# variable "namespace" {
#   description = "The namespace where the service account is created."
#   type        = string
# }

variable "namespaces" {
  description = "List of namespaces where the Docker registry secret should be created"
  type        = list(string)
  default     = ["backend", "frontend"]
}


variable "automount_service_account_token" {
  description = "Whether or not to automatically mount the service account token into the container. This defaults to true."
  type        = bool
  default     = false
}

variable "labels" {
  description = "(Optional) Map of string keys and values that can be used to organize and categorize (scope and select) namespaces. May match selectors of replication controllers and services."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "(Optional) An unstructured key value map stored with the namespace that may be used to store arbitrary metadata."
  type        = map(string)
  default     = {}
}

variable "kubernetes_secret" {
  type        = string
  default     = "null"
  description = "The name of the secret that will be created"
  sensitive   = true
}

variable "docker_repo" {
  type        = string
  default     = "null"
  description = "The name of the docker repo that will be created"
}

variable "docker_username" {
  type        = string
  default     = "kube"
  description = "The username for authenticating against the docker repo"
  sensitive   = true
}

variable "docker_password" {
  type        = string
  default     = "null"
  description = "The password for authenticating against the docker repo"
  sensitive   = true
}

variable "docker_email" {
  type        = string
  default     = "my@email.com"
  description = "The email for authenticating against the docker repo"
  sensitive   = true
}

variable "registry_server" {
  default = "dockerhub.com"
}
