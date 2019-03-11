variable "poc_bucket" {
  type        = "string"
  description = "Name of S3 bucket to store provisioning requests"
  default     = "grace-sqs-poc"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.poc_bucket}"
  acl           = "private"
  force_destroy = true
  region        = "us-east-1"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.kms_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "delete"
    enabled = true

    expiration {
      days = 7
    }
  }

  tags {
    Name = "GRACE API POC"
  }
}
