variable "name" {
  type = string
}

variable "stage" {
  type = string
}

resource "random_string" "suffix" {
  length = 8
  special = false
  upper = false
  lower = true
  number = false
}

resource "aws_s3_bucket" "state_storage" {
  bucket = "pipeline-${var.stage}-${var.name}-${random_string.suffix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

output "bucket_name" {
  value = "${aws_s3_bucket.state_storage.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.state_storage.arn}"
}
