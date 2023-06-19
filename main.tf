provider "aws" {}

resource "aws_sqs_queue" "step_function_input" {
  name = "step_function_input"
  sqs_managed_sse_enabled = false
}

locals {
  step_function_arn = format("arn:aws:states:%s:%s:stateMachine:step-function-demo",
    data.aws_region.current.id, data.aws_caller_identity.current.account_id)
}

data "aws_caller_identity" current {}
data aws_region current {}

resource "aws_sfn_state_machine" "demo" {
  name = "step-function-demo"
  role_arn   = aws_iam_role.step_function_role.arn
  definition = templatefile("state_machine.json", {
    CALCULATION_LAMBDA_ARN = aws_lambda_function.calculation.arn
    AGGREGATION_LAMBDA_ARN = aws_lambda_function.aggregation.arn
  })
}