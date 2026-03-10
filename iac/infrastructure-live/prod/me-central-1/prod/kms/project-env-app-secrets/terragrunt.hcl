include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=0.12.1"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


inputs = {
  description             = "Helm secrets for project Apps"
  deletion_window_in_days = 20
  enable_key_rotation     = false
  alias                   = format("alias/%s", include.root.locals.resource_name)
  tags = merge(
    {
      name = include.root.locals.resource_name
    },
    include.root.locals.base_tags,
  )

}