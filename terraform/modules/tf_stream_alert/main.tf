// Lambda Function: Rule Processor
//    Matches rules against logs from Kinesis, S3, or SNS
resource "aws_lambda_function" "streamalert_rule_processor" {
  function_name = "${var.prefix}_${var.cluster}_streamalert_rule_processor"
  description   = "StreamAlert Rule Processor"
  runtime       = "python2.7"
  role          = "${aws_iam_role.streamalert_rule_processor_role.arn}"
  handler       = "${var.lambda_handler}"
  memory_size   = "${var.rule_processor_memory}"
  timeout       = "${var.rule_processor_timeout}"

  filename         = "${var.filename}"
  source_code_hash = "${base64sha256(file(var.filename))}"
  publish          = true

  environment {
    variables = {
      ALERTS_TABLE   = "${var.prefix}_streamalert_alerts"
      CLUSTER        = "${var.cluster}"
      ENABLE_METRICS = "${var.rule_processor_enable_metrics}"
      LOGGER_LEVEL   = "${var.rule_processor_log_level}"
    }
  }

  tags {
    Name = "StreamAlert"
  }
}

// Lambda Alias: Rule Processor Production
resource "aws_lambda_alias" "rule_processor_production" {
  name             = "production"
  description      = "Production StreamAlert Rule Processor Alias"
  function_name    = "${aws_lambda_function.streamalert_rule_processor.arn}"
  function_version = "${aws_lambda_function.streamalert_rule_processor.version}"
}

// Log Retention Policy: Rule Processor
resource "aws_cloudwatch_log_group" "rule_processor" {
  name              = "/aws/lambda/${var.prefix}_${var.cluster}_streamalert_rule_processor"
  retention_in_days = "${var.cloudwatch_log_retention}"
}
