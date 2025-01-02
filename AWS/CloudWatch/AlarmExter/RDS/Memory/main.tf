provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxxxxxx"
}

variable "databases" {
  default = {
    db1 = {
      DBInstanceIdentifier = "prd-tss-db"
      project_name         = "PRD_TSS"
    }
  }
}

locals {
  sns_topics = flatten([
    for db_key, db in var.databases : [
      for alarm_type in ["WARNING", "CRITICAL", "NORMAL"] : {
        key          = "${db_key}_${alarm_type}"
        db_key       = db_key
        alarm_type   = alarm_type
        project_name = db.project_name
      }
    ]
  ])
}

# SNS Topics
resource "aws_sns_topic" "sns_topics" {
  for_each = { for topic in local.sns_topics : topic.key => topic }

  name = "${each.value.project_name}_RDS_FREEABLE_MEMORY_${each.value.alarm_type}"

  tags = {
    Environment  = "PRD"
    Project      = "Truck-Service"
    map-migrated = "migODJ2EO9APK"
  }
}

resource "aws_sns_topic_subscription" "sns_subscriptions" {
  for_each = aws_sns_topic.sns_topics

  topic_arn = each.value.arn
  protocol  = "email"
  endpoint  = "aws@pt.co.th"
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_warning" {
  for_each = var.databases

  alarm_name          = "${each.value.project_name}_RDS_FREEABLE_MEMORY_WARNING"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 4000000000 # 4 GB
  actions_enabled     = true
  alarm_description   = "RDS Freeable Memory <= 4 GB for 2/3 datapoints."

  dimensions = {
    DBInstanceIdentifier = each.value.DBInstanceIdentifier
  }

  alarm_actions = [
    aws_sns_topic.sns_topics["${each.key}_WARNING"].arn
  ]

  ok_actions = [
    aws_sns_topic.sns_topics["${each.key}_NORMAL"].arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "Truck-Service"
    map-migrated = "migODJ2EO9APK"
  }
}


resource "aws_cloudwatch_metric_alarm" "freeable_memory_critical" {
  for_each = var.databases

  alarm_name          = "${each.value.project_name}_RDS_FREEABLE_MEMORY_CRITICAL"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000000 # 1 GB
  actions_enabled     = true
  alarm_description   = "RDS Freeable Memory <= 1 GB for 2/3 datapoints."

  dimensions = {
    DBInstanceIdentifier = each.value.DBInstanceIdentifier
  }

  alarm_actions = [
    aws_sns_topic.sns_topics["${each.key}_CRITICAL"].arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "Truck-Service"
    map-migrated = "migODJ2EO9APK"
  }
}
