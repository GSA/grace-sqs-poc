resource "aws_lambda_function" "lambda" {
  filename         = "/tmp/lambda.zip"
  function_name    = "grace-sqs-poc"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda"
  runtime          = "go1.x"
  source_code_hash = "${base64sha256(file("/tmp/lambda.zip"))}"

  environment {
    variables = {
      GRACE_CUSTOMER_BUCKET  = "${aws_s3_bucket.s3_bucket.bucket}"
      GRACE_CUSTOMER_KMS_KEY = "${aws_kms_key.kms_key.key_id}"
      GRACE_CUSTOMER_PREFIX  = "sandbox"
    }
  }
}

resource "aws_lambda_event_source_mapping" "mapping" {
  event_source_arn = "${aws_sqs_queue.queue.arn}"
  function_name    = "${aws_lambda_function.lambda.arn}"
}
