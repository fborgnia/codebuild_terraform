variable "name" {
  type = string
}

variable "stage" {
  type = string
}

resource "random_string" "random" {
  length = 8
  special = false
  upper = false
  lower = true
  number = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = "pipeline-${var.stage}-${var.name}-${random_string.random.result}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

output "bucket_name" {
  value = "${aws_s3_bucket.bucket.id}"
}
