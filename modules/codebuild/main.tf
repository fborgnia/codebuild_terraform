provider "aws" {
    region = "us-east-1"
}

variable "name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "service_iam_role_arn" {
  type = string
}

variable "stage" {
  type = string
}

resource "aws_codebuild_project" "terraform_backend" {
  name          = "${var.name}-${var.stage}"
  description   = "${var.name} for ${var.stage} environment"
  build_timeout = "60"
  service_role  = "${var.service_iam_role_arn}"

  artifacts {
    type = "S3"
    name = "tfplan"
    location = "${var.bucket_name}" 
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "STAGE"
      value = "${var.stage}"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      status = "DISABLED"
    }
  }

  source {
    type     = "S3"
    location = "${var.bucket_name}/${var.name}.zip"
  }
}