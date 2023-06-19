resource "aws_iam_role" "lambda_role" {
  name = "step_function_lambda_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  inline_policy {
    name = "test_inline_policy"
    policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": ["${aws_sqs_queue.step_function_input.arn}"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:StartExecution"
            ],
            "Resource": ["${local.step_function_arn}"]
        }
    ]
}
EOF
  }
}

resource "aws_iam_role" "step_function_role" {
  name               = "step-function-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        }
      }
    ]
  }
  EOF
  inline_policy {
    name = "call_lambda_policy"
    policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": [
            "${aws_lambda_function.calculation.arn}",
            "${aws_lambda_function.aggregation.arn}"
        ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "states:StartExecution"
          ],
          "Resource": ["${local.step_function_arn}"]
      }
    ]
  }
EOF
  }
}
