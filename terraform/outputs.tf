output "secret" {
  value = "${aws_iam_access_key.key.secret}"
}

output "access_key" {
  value = "${aws_iam_access_key.key.id}"
}

output "url" {
  value = "${aws_sqs_queue.queue.id}"
}
