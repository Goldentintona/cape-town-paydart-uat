include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws//.?version=5.2.0"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


dependency "eks_cluster" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_managed_security_group_id = "sg-4545454"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "bastion_host" {
  config_path = "../project-env-ec2-bastion-host/"
  mock_outputs = {
    security_group_id = "sg-4545454"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "vpc" {
  config_path = "../../vpc/project.env.vpc"
  mock_outputs = {
    vpc_id              = "vpc-0557d70b7766b7799"
    ingress_cidr_blocks = ["0.0.0.0/0"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name                                                     = include.root.locals.resource_name
  description                                              = "Security group to allow Bastion Host and EKS traffic for the database"
  use_name_prefix                                          = false
  team                                                     = "${include.root.locals.env_vars.locals.team}"
  project                                                  = "${include.root.locals.env_vars.locals.project}"
  env                                                      = "${include.root.locals.env}"
  vpc_id                                                   = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks                                      = [dependency.vpc.outputs.vpc_cidr_block]
  number_of_computed_ingress_with_source_security_group_id = 2
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = dependency.bastion_host.outputs.security_group_id
    },
    {
      rule                     = "mysql-tcp"
      source_security_group_id = dependency.eks_cluster.outputs.eks_cluster_managed_security_group_id
    }
  ]

  tags = merge(
    {
      name = include.root.locals.resource_name
    },
    include.root.locals.base_tags,
  )
}
