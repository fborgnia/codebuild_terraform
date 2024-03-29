#terraform {
#  backend "s3" {
#    bucket = ""
#    key    = "terraform_state_files/codebuild_terraform_backend.tfstate"
#    region = "us-east-1"
#    encrypt = true
#    kms_key_id = 
#  }
#}

variable "app_name" {
  type = string
  description = "The name of the Application this pipeline releases."
}

variable "source_location" {
  type = string
  description = "The https url for the github enterprise repository of this app."
}

variable "stage" {
  type = string
  default = "dev"
  description = "The identifier for the environment stage: dev, test or prod?"
}

variable "http_proxy" {
  type = string
  description = "The utl:port for the proxy endpoint for outbound internet connectivity"
}