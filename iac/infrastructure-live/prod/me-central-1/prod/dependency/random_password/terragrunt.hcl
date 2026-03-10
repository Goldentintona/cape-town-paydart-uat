generate "random_password" {
  path      = "random_password.tf"
  if_exists = "overwrite"
  contents  = <<EOF
resource "random_password" "master" {
  length  = 20
  special = false
}

output "password" {
  value = random_password.master.result
  sensitive = true
}
EOF
}
inputs = {}
