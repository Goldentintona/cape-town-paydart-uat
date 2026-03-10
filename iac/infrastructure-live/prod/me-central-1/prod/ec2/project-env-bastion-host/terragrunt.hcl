include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws//.?version=5.7.0"

  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../../vpc/project.env.vpc",
    "../../datasources/",
    "../../security-groups/project-env-ec2-bastion-host",
    "../../keypair/project-env-bastion-host"
  ]
}


dependency "datasources" {
  config_path = "../../datasources/"
  mock_outputs = {
    ubuntu_2404_aws_ami_id = "ami-04cdc91e49cb06165"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]

}

dependency "vpc" {
  config_path = "../../vpc/project.env.vpc"
  mock_outputs = {
    vpc_id         = "vpc-0557d70b7766b7799"
    public_subnets = ["subnet-0d8ff9627adc20aca", "subnet-0d8ff9627adc20acb"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]

}

dependency "bastion_host_sg" {
  config_path = "../../security-groups/project-env-ec2-bastion-host"
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

inputs = {
  name                        = include.root.locals.resource_name
  team                        = "${include.root.locals.env_vars.locals.team}"
  project                     = "${include.root.locals.env_vars.locals.project}"
  env                         = "${include.root.locals.env}"
  ami                         = dependency.datasources.outputs.ubuntu_2404_aws_ami_id
  vpc_security_group_ids      = [dependency.bastion_host_sg.outputs.security_group_id]
  subnet_id                   = dependency.vpc.outputs.public_subnets[1]
  key_name                    = dependency.bastion_host_keypair.outputs.key_pair_name
  instance_count              = 1
  instance_type               = "${include.root.locals.env_vars.locals.bastion_host_instance_type}"
  disable_api_termination     = true
  monitoring                  = false
  tenancy                     = "default"
  assign_eip_address          = true
  associate_public_ip_address = true
  disk_size                   = 20
  ebs_optimized               = false
  ebs_volume_enabled          = true
  ebs_volume_type             = "gp2"
  ebs_volume_size             = 25
  user_data                   = "install_package.sh"

  tags = merge(
    {
      name = include.root.locals.resource_name
    },
    include.root.locals.base_tags,
  )

}
