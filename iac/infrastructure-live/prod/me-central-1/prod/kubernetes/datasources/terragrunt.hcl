include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../infrastructure-modules/kubernetes//datasource"
}


dependencies {
  paths = ["../../eks/project-env-eks"
  ]
}

dependency "eks_cluster" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_managed_security_group_id = "sg-4545454"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  ingress_name = "your-ingress-name"
  cluster_name = dependency.eks_cluster.outputs.eks_cluster_id
}
