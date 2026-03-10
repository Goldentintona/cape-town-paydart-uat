include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../infrastructure-modules/kubernetes//secret"
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
  paths = ["../../../eks/project-env-eks"]
}

dependency "eks" {
  config_path = "../../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name         = "${basename(get_terragrunt_dir())}"
  cluster_name = dependency.eks.outputs.eks_cluster_id

  registry_server = "https://index.docker.io/v1/"
  docker_username = get_env("DOCKER_USER")
  docker_password = get_env("DOCKER_TOKEN")
  docker_email    = "service_provider@paydart.co"
  namespaces      = ["backend", "frontend"]
}