include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/rds-aurora/aws//.?version=9.9.1"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


dependencies {
  paths = ["../../security-groups/project-env-rds-main",
    "../../vpc/project.env.vpc/",
    "../../dependency/random_password"
  ]
}

dependency "rds_sg" {
  config_path = "../../security-groups/project-env-rds-main"
  mock_outputs = {
    security_group_id = "sg-4545454"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


dependency "vpc" {
  config_path = "../../vpc/project.env.vpc/"
  mock_outputs = {
    vpc_id                      = "vpc-0557d70b7766b7799"
    database_subnet_group_name  = "dummy-vpc"
    private_subnets_cidr_blocks = ["10.2.1.0/24"]
    private_subnets             = ["subnet-00922230ad0761187", "subnet-0297c7aa6ff58b377", "subnet-05876cddac3947719"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "random_pass" {
  config_path = "../../dependency/random_password"
  mock_outputs = {
    password = "123456"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


inputs = {
  name        = include.root.locals.resource_name
  description = "REPLACE-ME Mysql"

  engine                      = "aurora-mysql"
  engine_version              = "8.0"
  storage_encrypted           = true
  master_username             = "root"
  manage_master_user_password = false
  master_password             = dependency.random_pass.outputs.password


  vpc_id                = dependency.vpc.outputs.vpc_id
  db_subnet_group_name  = dependency.vpc.outputs.database_subnet_group_name
  create_security_group = false
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
    }

    project_ingress = {
      source_security_group_id = dependency.rds_sg.outputs.security_group_id
    }
  }
  vpc_security_group_ids = [dependency.rds_sg.outputs.security_group_id]

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true




  instance_class = "db.r5.large"
  instances = {
    1 = {}
  }

  autoscaling_enabled      = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 2

  autoscaling_policy_name = include.root.locals.resource_name
  autoscaling_target_cpu  = 80


  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = include.root.locals.resource_name
  db_cluster_parameter_group_family      = "aurora-mysql8.0"
  db_cluster_parameter_group_description = include.root.locals.resource_name
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 10
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 50
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "TABLE"
      apply_method = "immediate"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
      }, {
      name         = "binlog_format"
      value        = "MIXED"
      apply_method = "pending-reboot"
      }, {
      name         = "tls_version"
      value        = "TLSv1.2,TLSv1.3"
      apply_method = "pending-reboot"
    }
  ]
  tags = merge(
    {
      name = include.root.locals.resource_name
    },
    include.root.locals.base_tags,
  )
}
