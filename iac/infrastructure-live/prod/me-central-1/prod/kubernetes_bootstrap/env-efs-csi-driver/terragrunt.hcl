include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../infrastructure-modules//helm"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}


dependencies {
  paths = ["../../eks/project-env-eks",
    "../../iam-role/project.env.eks.serviceaccounts",
  ]
}



dependency "eks" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  cluster_name = dependency.eks.outputs.eks_cluster_id

  name                 = "aws-efs-csi-driver"
  kubernetes_namespace = "kube-system"
  repository           = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart                = "aws-efs-csi-driver"
  description          = "AWS EFS CSI Driver for Kubernetes"
  chart_version        = "3.0.8" # 2.3.2

  reset_values = true
  reuse_values = true
  timeout      = 120
  values       = [file("./values.yaml")]

  set = [
    {
      name  = "controller.serviceAccount.create"
      value = "false"
      type  = "auto"
    },

    {
      name  = "controller.serviceAccount.name"
      value = "efs-csi-controller-sa"
      type  = "string"
    }
  ]


}
