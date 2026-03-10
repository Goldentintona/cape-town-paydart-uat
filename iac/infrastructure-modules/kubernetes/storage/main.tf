data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}



resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = var.name
  }

  storage_provisioner = var.provisioner
  parameters = {
    provisioningMode = "efs-ap"
    directoryPerms   = "700"
  }

  mount_options = [
    "iam"
  ]
  # parameters = {
  #   provisioningMode      = var.provisioningmode
  #   fileSystemId          = var.filesystemid
  #   directoryPerms        = var.directoryperms
  #   gidRangeStart         = var.gidrangestart
  #   gidRangeEnd           = var.gidrangeend
  #   basePath              = var.basepath
  #   subPathPattern        = var.subpathpattern
  #   ensureUniqueDirectory = var.ensureuniquedirectory
  #   reuseAccessPoint      = var.reuseaccesspoint
  # }
}