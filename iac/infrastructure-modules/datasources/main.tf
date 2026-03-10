variable "acm_domain" {
  description = "The domain of the certificate to look up. If no certificate is found with this name, an error will be returned."
  type        = string
}
data "aws_region" "selected" {}

data "aws_availability_zones" "available" {}

# aws ec2 describe-images --image-ids ami-05d1e0e430e0bc2bb

data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_cloudfront_origin_request_policy" "managed_cors_s3origin" {
  name = "Managed-CORS-S3Origin"
}

//data "aws_cloudfront_cache_policy" "managed_cache_optimized" {
//  name = "PayDart-CachingOptimized"
//}

