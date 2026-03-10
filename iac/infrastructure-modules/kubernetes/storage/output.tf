output "storage_class_name" {
  description = "The name of the created storage class"
  value       = kubernetes_storage_class_v1.efs.metadata[0].name
}