include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "../../../../../../infrastructure-modules//acm"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region              = "us-east-1"
}
EOF
}



inputs = {
  name               = include.root.locals.resource_name
  private_key        = "~/REPLACE-ME.key"
  certificate_body   = "~/REPLACE-ME.crt"
  certificate_chain  = "~/chain.crt"
  import_certificate = true
  tags = merge(
    { Name = include.root.locals.resource_name },
    include.root.locals.base_tags
  )
}