include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks?version=5.44.0"

  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


dependencies {
  paths = ["../../eks/project-env-eks"]
}

dependency "eks" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_identity_oidc_issuer_arn = "arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  role_name                              = include.root.locals.resource_name
  attach_ebs_csi_policy                  = true
  attach_efs_csi_policy                  = true
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    csi = {
      provider_arn               = dependency.eks.outputs.eks_cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
    alb = {
      provider_arn               = dependency.eks.outputs.eks_cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = merge(
    include.root.locals.base_tags,
  )

}
