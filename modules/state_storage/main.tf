variable "name" {
  type = string
}

variable "stage" {
  type = string
}

variable "kms_key_id" {
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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.kms_key_id}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_iam_policy_document" "state_storage_encryption_policy_doc" {
  statement {
    sid = "DenyIncorrectEncryptionHeader"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.state_storage.arn}/*"
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "aws:kms"
      ]
    }
  }

  statement {
    sid = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.state_storage.arn}/*",
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "state_storage_encryption_policy" {
  bucket = "${aws_s3_bucket.state_storage.id}"

  policy = "${data.aws_iam_policy_document.state_storage_encryption_policy_doc.json}"
}

output "bucket_name" {
  value = "${aws_s3_bucket.state_storage.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.state_storage.arn}"
}
