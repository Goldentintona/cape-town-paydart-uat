# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//.?version=5.13.0"
  extra_arguments "init_args" {
    commands = ["init"]
  }
}

dependency "aws-data" {
  config_path = "../../datasources"
  mock_outputs = {
    available_aws_availability_zones_names = ["me-central-1a", "me-central-1b", "me-central-1c"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC CONFIGURATION INPUTS
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  name    = include.root.locals.resource_name
  azs     = [for v in dependency.aws-data.outputs.available_aws_availability_zones_names : v]
  cidr    = include.root.locals.env_vars.locals.cidr
  team    = include.root.locals.env_vars.locals.team
  project = include.root.locals.env_vars.locals.project
  env     = include.root.locals.env

  # Subnet configurations using CIDR blocks
  private_subnets = [for k, v in dependency.aws-data.outputs.available_aws_availability_zones_names :
  cidrsubnet(include.root.locals.env_vars.locals.cidr, 8, k + 1)]
  public_subnets = [for k, v in dependency.aws-data.outputs.available_aws_availability_zones_names :
  cidrsubnet(include.root.locals.env_vars.locals.cidr, 8, k + 11)]
  database_subnets = [for k, v in dependency.aws-data.outputs.available_aws_availability_zones_names :
  cidrsubnet(include.root.locals.env_vars.locals.cidr, 8, k + 21)]

  # General VPC settings
  create_database_subnet_group = true
  enable_dns_support           = true
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  one_nat_gateway_per_az       = true

  # Network ACL settings
  # manage_default_network_acl = true
  # default_network_acl_ingress = [
  #   { rule_no = 100, action = "allow", from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0" },
  #   { rule_no = 105, action = "allow", from_port = 80, to_port = 80, protocol = "tcp", ipv6_cidr_block = "::/0" },
  #   { rule_no = 110, action = "allow", from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0" },
  #   { rule_no = 115, action = "allow", from_port = 443, to_port = 443, protocol = "tcp", ipv6_cidr_block = "::/0" },
  #   { rule_no = 120, action = "allow", from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "0.0.0.0/0" },
  #   { rule_no = 130, action = "allow", from_port = 3389, to_port = 3389, protocol = "tcp", cidr_block = "0.0.0.0/0" },
  #   { rule_no = 140, action = "allow", from_port = 3390, to_port = 65535, protocol = "tcp", cidr_block = "0.0.0.0/0" },
  #   { rule_no = 150, action = "allow", from_port = 3390, to_port = 65535, protocol = "tcp", ipv6_cidr_block = "::/0" },
  #   { rule_no = 160, action = "allow", from_port = 1194, to_port = 1194, protocol = "udp", cidr_block = "0.0.0.0/0" },
  #   { rule_no = 170, action = "allow", from_port = 3306, to_port = 3306, protocol = "tcp", cidr_block = include.root.locals.env_vars.locals.cidr },
  #   { rule_no = 180, action = "allow", from_port = 0, to_port = 0, protocol = "-1", cidr_block = include.root.locals.env_vars.locals.cidr }
  # ]

  # Tag configuration
  tags = merge(
    { Name = include.root.locals.resource_name },
    include.root.locals.base_tags
  )

  public_subnet_tags = {
    Name                     = format("%s-public", include.root.locals.resource_name)
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    Name = format("%s-private", include.root.locals.resource_name)
  }
  database_subnet_tags = {
    Name = format("%s-db", include.root.locals.resource_name)
  }
}
