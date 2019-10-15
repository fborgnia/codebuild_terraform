provider "aws" {
    region = "us-east-1"
} 

module "iam" {
  source = "./modules/iam"
  name = "codebuild-role-terraform-${var.name}-${var.stage}"
}

module "s3" {
  source = "./modules/s3"
  name = "${var.name}"
  stage = "${var.stage}"
}

module "codebuild" {
  source               = "./modules/codebuild"
  name 				   = "${var.name}"
  bucket_name	       = "${module.s3.bucket_name}"
  service_iam_role_arn = "${module.iam.service_iam_role_arn}"
  stage			       = "${var.stage}"
}