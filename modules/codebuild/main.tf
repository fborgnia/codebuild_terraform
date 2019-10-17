provider "aws" {
    region = "us-east-1"
}

variable "name" {
  type = string
}

variable "state_storage" {
  type = string
}

variable "state_storage_key" {
  type = string
}

variable "service_iam_role_arn" {
  type = string
}

variable "stage" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "http_proxy" {
  type = string
}

variable "source_location" {
  type = string
  description = "The https url for the github enterprise repository of this app."
}

resource "aws_codebuild_project" "terraform_backend" {
  name           = "${var.name}-${var.stage}"
  description    = "${var.name} for ${var.stage} environment"
  build_timeout  = "60"
  service_role   = "${var.service_iam_role_arn}"
  encryption_key = "${var.state_storage_key}"
  
  artifacts {
    type = "S3"
    name = "tfplan"
    location = "${var.state_storage}" 
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

    environment_variable {
      name  = "HTTP_PROXY"
      value = "${var.http_proxy}"
    }

    environment_variable {
      name  = "HTTPS_PROXY"
      value = "${var.http_proxy}"
    }

    environment_variable {
      name  = "http_proxy"
      value = "${var.http_proxy}"
    }

    environment_variable {
      name  = "https_proxy"
      value = "${var.http_proxy}"
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
    type            = "GITHUB"
    location        = "https://github.com/fborgnia/example_app.git"
    git_clone_depth = 1
  }

  #source {
  #  type            = "GITHUB_ENTERPRISE"
  #  location        = "${var.source_location}"
  #  git_clone_depth = 1
  #}

  vpc_config {
    vpc_id = "${var.vpc_id}"

    subnets = "${var.subnets}"

    security_group_ids = [
      "${var.security_group_id}"
    ]
  }
}

output "project_name" {
  value = "${aws_codebuild_project.terraform_backend.id}"
}