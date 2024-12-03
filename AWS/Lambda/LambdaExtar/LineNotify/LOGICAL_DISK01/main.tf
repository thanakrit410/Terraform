provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxx"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "Alarm_lsretail-logicaldisk01"
  runtime       = "python3.12"
  role          = "arn:aws:iam::031103279384:role/AlarmNotificationLambdaExecutionRole"
  handler       = "lambda_function.lambda_handler"

  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }

  environment {
    variables = {
      LINE_NOTIFY_API_URL = "https://notify-api.line.me/api/notify"
      LINE_NOTIFY_TOKEN   = "fFhY3KtnBRzPE73qrsFAKbNWSVv6gFYBdcFpRgGoTtA"
    }
  }

  architectures = ["arm64"]

}

locals {
  existing_sns_topics = [
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_BATCH_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_BATCH_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_BATCH_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_HQ_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_INF_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_ACTVDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_AZ1A_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_AZ1B_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_MASTER_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_OMNI_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_REPORTING_DB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",

    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_REPORTING_DB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_REPORTING_DB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_STAGING_ATCVDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_STAGING_ATCVDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_STAGING_ATCVDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_STAGING_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_CRITICAL",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_STAGING_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_NORMAL",
    # "arn:aws:sns:ap-southeast-1:031103279384:PRD_LSRETAIL_STAGING_STBYDB_EC2_LOGICAL_DISK01_FREE_SPACE_WARNING",
  ]
}

resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
  for_each  = toset(local.existing_sns_topics)
  topic_arn = each.value
  protocol  = "lambda"
  endpoint  = aws_lambda_function.my_lambda.arn
}

resource "aws_lambda_permission" "allow_sns" {
  for_each = toset(local.existing_sns_topics)

  statement_id  = "AllowSNSInvoke-${substr(sha256(each.value), 0, 12)}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = each.value
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}