include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "tfr:///mineiros-io/iam-policy/aws//?version=0.5.2"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../../kms/project-env-app-secrets"]
}

dependency "kms_arn" {
  config_path = "../../kms/project-env-app-secrets"
  mock_outputs = {
    alias_arn = "arn:aws:kms:af-south-1:617217039186:alias/gti-paydart-uat-app-secrets"
    key_arn   = "arn:aws:kms:af-south-1:617217039186:key/fe443d4d-dd8b-482b-83bc-2c9dae929dbd"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name        = include.root.locals.resource_name
  description = "Allows ArgoCd to Decrypt/Encrypt app secrets"
  policy_statements = [
    {
      sid    = "ArgoCDKMS"
      effect = "Allow"
      actions = [
        "kms:Decrypt*",
        "kms:Encrypt*",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*",
        "kms:DescribeKey",
      ]
      resources = [dependency.kms_arn.outputs.key_arn
      ]
    }
  ]
  tags = merge(
    include.root.locals.base_tags,
  )

}
