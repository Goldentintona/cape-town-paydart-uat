include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "tfr:///cloudposse/efs/aws//.?version=1.0.0"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


dependencies {
  paths = ["../../vpc/project.env.vpc", "../../eks/project-env-eks", "../../security-groups/project-env-efs"]
}

dependency "vpc" {
  config_path = "../../vpc/project.env.vpc"
  mock_outputs = {
    vpc_id          = "vpc-0557d70b7766b7799"
    public_subnets  = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
    private_subnets = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "eks_cluster" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_managed_security_group_id = "sg-4545454"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "efs_sg" {
  config_path = "../../security-groups/project-env-efs"
  mock_outputs = {
    security_group_id = "sg-4545454"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


inputs = {
  name                       = include.root.locals.resource_name
  security_group_name        = [format("%s-efs", include.root.locals.resource_name)]
  region                     = "${include.root.locals.aws_region}"
  allowed_security_group_ids = [dependency.eks_cluster.outputs.eks_cluster_managed_security_group_id,
                                dependency.efs_sg.outputs.security_group_id]
  vpc_id                     = dependency.vpc.outputs.vpc_id
  subnets                    = dependency.vpc.outputs.private_subnets
  efs_backup_policy_enabled  = true
  tags = merge(
    {
      name = include.root.locals.resource_name
    },
    include.root.locals.base_tags,
  )

}
