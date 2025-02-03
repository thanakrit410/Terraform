provider "aws" {
  region = "ap-southeast-1"
  access_key = "AXXXXXXXXXXXXXXXXXXX"
  secret_key = "BXXXXXXXXXXXXXXXXXXX"
}

resource "aws_iam_role" "lambda_rds_role" {
  name = "LambdaStopRDSExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "LambdaStopRDSInlinePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "rds:DescribeDBInstances",
            "rds:ListTagsForResource",
            "rds:StopDBInstance"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "lambda:InvokeFunction"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "rds_lambda" {
  function_name = "Stop_rds_from_tag"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_rds_role.arn
  handler       = "lambda_function.lambda_handler"
  filename = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  tags = {

    Environment = "nonprd"
    map-migrated = "migODJ2EO9APK"
    Project = "Infrastructure"

  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.rds_lambda.arn
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "Stop_rds_from_tag"
  description         = "Trigger Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}


resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.rds_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}


