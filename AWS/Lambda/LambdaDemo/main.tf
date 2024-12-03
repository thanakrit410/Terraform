provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "lambda-cloudwatch-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*"
        }
      ]
    })
  }

}

resource "aws_lambda_function" "my_lambda" {
  function_name = "MyTerraformLambda"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"

  filename = "${path.module}/lambda_function.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  tags = {
    Environment = "Dev"
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}