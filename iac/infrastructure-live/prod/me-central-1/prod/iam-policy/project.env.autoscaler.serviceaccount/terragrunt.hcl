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
  description = "Allows Autoscaler to add remove EKS nodes"
  policy_statements = [
    {
      sid    = "AllowToScaleEKSNodeGroupAutoScalingGroup"
      effect = "Allow"
      actions = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "rds:AddTagsToResource",
      ]
      resources = ["*"]
    }
  ]
  tags = merge(
    include.root.locals.base_tags,
  )

}
