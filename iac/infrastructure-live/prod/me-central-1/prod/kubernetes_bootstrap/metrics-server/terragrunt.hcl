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
  paths = ["../../eks/project-env-eks"]
}

dependency "eks" {
  config_path = "../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


inputs = {
  name = replace("${basename(get_terragrunt_dir())}", "env", "${include.root.locals.env}")

  cluster_name         = dependency.eks.outputs.eks_cluster_id
  kubernetes_namespace = "kube-system"

  repository    = "https://kubernetes-sigs.github.io/metrics-server"
  chart         = "metrics-server"
  description   = "Metrics server resource metrics for Kubernetes"
  chart_version = "3.12.2"

  reset_values = true
  reuse_values = true
  timeout      = 320
  values       = [file("./values.yaml")]

  set = [
    {
      name  = "apiService.insecureSkipTLSVerify"
      value = true
      type  = "auto"
    }
  ]


}