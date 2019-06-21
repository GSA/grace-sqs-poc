resource "aws_sqs_queue" "queue" {
  name                      = "grace-sqs-poc"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Deny",
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:grace-sqs-poc",
      "Condition": {"NotIpAddress": {"aws:SourceIp": "149.96.5.118"}}
    }
  }
EOF
}
