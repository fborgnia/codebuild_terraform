resource "aws_kms_key" "state_storage_encryption_key" {
  description             = "Encryption Key for Terraform State Backend S3 Bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = false
  is_enabled 			  = true
}

output "kms_key_id" {
  value = "${aws_kms_key.state_storage_encryption_key.key_id}"
}

output "kms_key_arn" {
  value = "${aws_kms_key.state_storage_encryption_key.arn}"
}