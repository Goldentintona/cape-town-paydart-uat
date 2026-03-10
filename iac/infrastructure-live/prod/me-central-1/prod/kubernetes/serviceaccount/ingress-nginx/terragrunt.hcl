include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../infrastructure-modules/kubernetes//serviceaccount"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../../../eks/project-env-eks",
    "../../../iam-role/project.env.eks.serviceaccounts"
  ]
}

dependency "eks" {
  config_path = "../../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "iam_service_account_role" {
  config_path = "../../../iam-role/project.env.eks.serviceaccounts"
  mock_outputs = {
    iam_role_arn = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name                            = "${basename(get_terragrunt_dir())}"
  namespace                       = "ingress-nginx"
  automount_service_account_token = true
  cluster_name                    = dependency.eks.outputs.eks_cluster_id

  labels = {
    "app.kubernetes.io/name"      = "ingress-nginx"
    "app.kubernetes.io/component" = "controller"
  }
  annotations = {
    "eks.amazonaws.com/role-arn"               = dependency.iam_service_account_role.outputs.iam_role_arn
    "eks.amazonaws.com/sts-regional-endpoints" = "true"
  }

}
