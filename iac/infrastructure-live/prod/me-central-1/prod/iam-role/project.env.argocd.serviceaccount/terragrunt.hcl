include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc?version=5.29.0"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

dependencies {
  paths = ["../../iam-policy/project.env.argocd.serviceaccount",
  "../../eks/project-env-eks"]
}

dependency "argocd" {
  config_path = "../../iam-policy/project.env.argocd.serviceaccount"
  mock_outputs = {
    arn = "0557d70b7766b7799"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


dependency "eks" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_identity_oidc_issuer_arn = "arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  role_name                     = include.root.locals.resource_name
  description                   = "Allows Argocd to Decrypt keys"
  create_role                   = true
  provider_url                  = trimprefix(dependency.eks.outputs.eks_cluster_identity_oidc_issuer, "https://")
  role_policy_arns              = [dependency.argocd.outputs.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:argocd:argocd-repo-server"]

  tags = merge(
    include.root.locals.base_tags,
  )

}
