resource "aws_iam_role" "role" {
  name        = "grace-sqs-poc"
  description = "Role for GRACE SQS POC Lambda function"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "graceSQSLambda"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "grace-sqs-poc"
  description = "Policy GRACE SQS POC"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "graceSQSLambdaLogging"
    },
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:iam::*:role/grace-sqs-poc"
      ],
      "Sid": "graceSQSLambdaSTS"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.s3_bucket.arn}/*",
      "Sid": "graceSQSLambdaS3"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt"
      ],
      "Resource": "${aws_kms_key.kms_key.arn}",
      "Sid": "graceSQSLambdaKMS"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Resource": "${aws_sqs_queue.queue.arn}",
      "Sid": "graceSQSLambdaSQS"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

//ServiceNow Service account IAM User
resource "aws_iam_user" "user" {
  name = "service.serviceNow"
}

resource "aws_iam_user_policy" "user_policy" {
  name = "grace-sqs-poc"
  user = "${aws_iam_user.user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:SendMessage"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.queue.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "key" {
  user = "${aws_iam_user.user.name}"
}
