provider "aws" {
  region = "us-east-1"
}

variable "name" {
  type = string
}

variable "state_storage_arn" {
  type = string
}

resource "aws_iam_role" "codebuild_service_role" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "state_storage_policy_doc" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${var.state_storage_arn}",
    ]
  }
}

resource "aws_iam_role_policy" "state_storage_policy" {
  role = "${aws_iam_role.codebuild_service_role.name}"
  policy = "${data.aws_iam_policy_document.state_storage_policy_doc.json}"
}

data "aws_iam_policy_document" "codebuild_logs_policy_doc" {
  statement {
    sid = "1"

    actions = [
      "*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_logs_policy" {
  role = "${aws_iam_role.codebuild_service_role.name}"
  policy = "${data.aws_iam_policy_document.codebuild_logs_policy_doc.json}"
}

data "aws_iam_policy_document" "terraform_run_policy_doc" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "terraform_run_policy" {
  role = "${aws_iam_role.codebuild_service_role.name}"
  policy = "${data.aws_iam_policy_document.terraform_run_policy_doc.json}"
}


output "codebuild_service_iam_role_arn" {
  value = "${aws_iam_role.codebuild_service_role.arn}"
}