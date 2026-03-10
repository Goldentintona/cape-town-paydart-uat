# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "uat"
  aws_account_id = "617217039186"
  aws_profile    = "placid-gti-root"
}
