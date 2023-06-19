data "archive_file" "lambda_package" {
  source_file = "aws_lambdas.py"
  output_path = "aws_lambdas.zip"
  type        = "zip"
}

resource "aws_lambda_function" "start" {
  function_name = "step_function_start"
  role          = aws_iam_role.lambda_role.arn
  memory_size = 128
  timeout = 30
  filename = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime = "python3.10"
  handler = "aws_lambdas.start"
  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.demo.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "event_mapping" {
  event_source_arn = aws_sqs_queue.step_function_input.arn
  function_name = aws_lambda_function.start.function_name
  batch_size = 1
}

resource "aws_lambda_function" "calculation" {
  function_name = "step_function_calculation"
  role          = aws_iam_role.lambda_role.arn
  memory_size = 128
  timeout = 60
  filename = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime = "python3.10"
  handler = "aws_lambdas.calculate"
}

resource "aws_lambda_function" "aggregation" {
  function_name = "step_function_aggregation"
  role          = aws_iam_role.lambda_role.arn
  memory_size = 128
  timeout = 30
  filename = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime = "python3.10"
  handler = "aws_lambdas.aggregate"
}