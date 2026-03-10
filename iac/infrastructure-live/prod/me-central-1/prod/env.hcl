# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment                = "uat"
  team                       = "devops"
  project                    = "gti-paydart-af1"
  domain_name                = "gtipayglobal.com"
  cidr                       = "172.16.0.0/16"
  bastion_host_instance_type = "t3.nano"

}
