include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "tfr:///terraform-aws-modules/key-pair/aws//.?version=2.0.3"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

inputs = {
  key_name   = include.root.locals.resource_name
  public_key = get_env("gti")

  tags = merge(
    {
      name = include.root.locals.resource_name
    },
    include.root.locals.base_tags,
  )

}
//ssh-keygen  -C "uat_REPLACE-ME_test" -f ./uat_REPLACE-ME_test
//export REPLACE-ME_KEY=$(cat ./uat_REPLACE-ME_test.pub)
