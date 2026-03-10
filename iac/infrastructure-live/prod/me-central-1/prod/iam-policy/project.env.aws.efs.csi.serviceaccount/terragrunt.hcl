include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "tfr:///mineiros-io/iam-policy/aws//?version=0.5.2"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

inputs = {
  name        = include.root.locals.resource_name
  description = "Allows CSI driver's service account to make calls to AWS APIs"
  policy_statements = [
    {
      sid    = "AllowEFSDescribeActions"
      effect = "Allow"
      actions = [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
        "ec2:DescribeAvailabilityZones"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowEFSCreateAccessPoint"
      effect = "Allow"
      actions = [
        "elasticfilesystem:CreateAccessPoint"
      ]
      resources = ["*"]
      condition = {
        StringLike = {
          "aws:RequestTag/efs.csi.aws.com/cluster" = "true"
        }
      }
    },
    {
      sid    = "AllowEFSTagResource"
      effect = "Allow"
      actions = [
        "elasticfilesystem:TagResource"
      ]
      resources = ["*"]
      condition = {
        StringLike = {
          "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
        }
      }
    },
    {
      sid    = "AllowEFSDeleteAccessPoint"
      effect = "Allow"
      actions = [
        "elasticfilesystem:DeleteAccessPoint"
      ]
      resources = ["*"]
      condition = {
        StringEquals = {
          "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
        }
      }
    },
    {
      sid    = "AllowEFSClientMount"
      effect = "Allow"
      actions = [
         "elasticfilesystem:ClientRootAccess",
         "elasticfilesystem:ClientWrite",
         "elasticfilesystem:ClientMount",
      ]
      resources = ["*"]
      condition = {
        StringEquals = {
          "elasticfilesystem:AccessedViaMountTarget" = "true"
        }
      }
    }






  ]

  tags = merge(
    include.root.locals.base_tags,
  )

}
