terraform {
  backend "s3" {
    bucket = "pipeline-dev-example-app-ulwydhpc"
    key    = "terraform_state_files/codebuild_terraform_backend.tfstate"
    region = "us-east-1"
  }
}

variable "name" {
  type = string
}

variable "stage" {
  type = string
}