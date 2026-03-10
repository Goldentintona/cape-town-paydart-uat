# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt provides additional functionality for Terraform, enabling management of multiple modules,
# remote state storage, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Load configurations from parent directories
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Define key variables for use in this configuration
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  env          = local.env_vars.locals.environment
  project      = local.env_vars.locals.project

  # Resource directory name
  base_name = basename(path_relative_to_include())

  # Normalize "project.env", "project-env", or "project_env" in resource directory name to the dynamic project and environment name
  resource_name = replace(
    replace(
      replace(local.base_name, "project.env", "${local.project}.${local.env}"),
      "project-env", "${local.project}-${local.env}"
    ),
    "project_env", "${local.project}_${local.env}"
  )

  # Set base tags to be used across all resources
  base_tags = {
    Project        = local.project
    Team           = local.env_vars.locals.team
    Tier           = local.env
    Account_id     = local.account_id
    Terraform_path = path_relative_to_include()
  }
}

#Keep your CLI DRY, Before, After, Error hooks 
terraform {
  extra_arguments "common" {
    commands = [
      "auto-approve",
      "plan",
      "apply"
    ]

  }
    before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo","Start Terraform"]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Finished running Terraform"]
    run_on_error = true
  }
    error_hook "import_resource" {
    commands  = ["apply"]
    execute   = ["echo", "Error Hook executed"]
    on_errors = [
      ".*",
    ]
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region             = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Optionally override Terraform version constraints for the AWS provider
# Uncomment and customize if needed
# generate "versions" {
#   path      = "versions_override.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "= 3.74.1"
#     }
#   }
# }
# EOF
# }

# Configure remote state storage in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.project}.${local.env}.terragrunt.state.${local.account_id}.${local.aws_region}"
    key            = "${local.env}/${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region         = local.aws_region
    # Uncomment and configure if needed:
    # role_arn       = local.role_arn
    # external_id    = local.external_id
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# Global variables applied to all configurations in this directory, automatically merged into child `terragrunt.hcl`.
# ---------------------------------------------------------------------------------------------------------------------

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals
)
