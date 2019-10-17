provider "aws" {
  region = "us-east-1"
} 

module "kms_encryption_key" {
  source = "./modules/kms_encryption_key"
}

module "vpc" {
  source = "./modules/vpc"
  name   = "${var.app_name}"
}

module "state_storage" {
  source          = "./modules/state_storage"
  kms_key_id      = "${module.kms_encryption_key.kms_key_id}"
  name            = "${var.app_name}"
  stage           = "${var.stage}"
}

module "iam_roles" {
  source             = "./modules/iam_roles"
  name               = "codebuild-role-terraform-${var.app_name}-${var.stage}"
  kms_key_arn        = "${module.kms_encryption_key.kms_key_arn}" 
  state_storage_arn  = "${module.state_storage.bucket_arn}" 
}

module "codebuild" {
  source                = "./modules/codebuild"
  name 				          = "${var.app_name}"
  http_proxy            = "${var.http_proxy}"
  source_location       = "${var.source_location}"
  state_storage         = "${module.state_storage.bucket_name}"
  state_storage_key     = "${module.kms_encryption_key.kms_key_arn}"
  service_iam_role_arn  = "${module.iam_roles.codebuild_service_iam_role_arn}"
  stage			            = "${var.stage}"
  vpc_id                = "${module.vpc.vpc_id}"
  subnets               = ["${module.vpc.subnet_1a}", "${module.vpc.subnet_1b}"]
  security_group_id     = "${module.vpc.security_group_id}"
}

output "codebuild" {
  value = "${module.codebuild.project_name}"
}

output "state_backend_bucket_name" {
  value = "${module.state_storage.bucket_name}"
}