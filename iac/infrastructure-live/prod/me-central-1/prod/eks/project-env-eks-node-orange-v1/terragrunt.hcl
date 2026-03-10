include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///cloudposse/eks-node-group/aws//.?version=3.1.0"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../project-env-eks",
    "../../vpc/project.env.vpc/",
    "../../keypair/project-env-bastion-host/",
    "../../security-groups/project-env-efs"
  ]
}

dependency "vpc" {
  config_path = "../../vpc/project.env.vpc/"
  mock_outputs = {
    vpc_id          = "vpc-0557d70b7766b7799"
    private_subnets = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "efs_sg" {
  config_path = "../../security-groups/project-env-efs"
  mock_outputs = {
    security_group_id = "87c6c06"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}



dependency "bastion_host_keypair" {
  config_path = "../../keypair/project-env-bastion-host"
  mock_outputs = {
    key_pair_name = "my-fake-key"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


dependency "eks_cluster" {
  config_path = "../project-env-eks"
  mock_outputs = {
    eks_cluster_id       = "0557d70b7766b7799"
    eks_cluster_endpoint = "https://region.eks.amazonaws.com/"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}



inputs = {
  name                          = include.root.locals.resource_name
  subnet_ids                    = dependency.vpc.outputs.private_subnets
  cluster_name                  = dependency.eks_cluster.outputs.eks_cluster_id
  instance_types                = ["t3.medium", "c5.large", "c5d.large"]
  desired_size                  = 1
  min_size                      = 1
  max_size                      = 5
  ec2_ssh_key_name              = [dependency.bastion_host_keypair.outputs.key_pair_name]
  associated_security_group_ids = [dependency.efs_sg.outputs.security_group_id]
  metadata_http_tokens_required = false
  node_role_policy_arns         = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  block_device_mappings = [{
    device_name           = "/dev/xvda"
    volume_size           = 30
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }]

  cluster_autoscaler_enabled = true
  capacity_type              = "SPOT"
  environment                = ""

  kubernetes_labels = {
    orange = "true"
  }

  kubernetes_taints = [
    {
      key    = "workload"
      value  = "orange"
      effect = "NO_SCHEDULE"
    }
  ]


  cluster_depends_on = [dependency.eks_cluster.outputs.eks_cluster_endpoint]

  tags = merge(
    include.root.locals.base_tags,
  )
  resources_to_tag = ["instance", "volume"]

}