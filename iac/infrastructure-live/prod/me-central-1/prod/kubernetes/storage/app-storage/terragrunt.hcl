include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../infrastructure-modules/kubernetes//storage"
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
  paths = ["../../../eks/project-env-eks", "../../../efs/project-env-cluster-app"]
}


dependency "eks" {
  config_path = "../../../eks/project-env-eks"
  mock_outputs = {
    eks_cluster_id = "k8s"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "efs" {
  config_path = "../../../efs/project-env-cluster-app"
  mock_outputs = {
    id = "fs-XXXXXXX"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  name         = "${basename(get_terragrunt_dir())}"
  cluster_name = dependency.eks.outputs.eks_cluster_id

  provisioner = "efs.csi.aws.com"

  # provisioningmode      = "efs-ap"
  # filesystemid          = dependency.efs.outputs.id
  # directoryperms        = "700"
  # gidrangestart         = "1000"
  # gidrangeend           = "2000"
  # basepath              = "/pay"
  # subpathpattern        = "$${.PVC.namespace}/$${.PVC.name}"
  # ensureuniquedirectory = "true"
  # reuseaccesspoint      = "false"
}
