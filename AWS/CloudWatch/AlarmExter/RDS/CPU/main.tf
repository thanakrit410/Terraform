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

  name = "${each.value.project_name}_RDS_CPU_UTILIZATION_${each.value.alarm_type}"

  tags = {
    Environment  = "PRD"
    Project      = "Truck-Service"
    map-migrated = "migODJ2EO9APK"
  }
}

# SNS Subscriptions
resource "aws_sns_topic_subscription" "sns_subscriptions" {
  for_each = aws_sns_topic.sns_topics

  topic_arn = each.value.arn
  protocol  = "email"
  endpoint  = "aws@pt.co.th"
}

# CloudWatch Metric Alarms (CPU Utilization - Warning)
resource "aws_cloudwatch_metric_alarm" "metric_alarms" {
  for_each = var.databases

  alarm_name          = "${each.value.project_name}_RDS_CPU_UTILIZATION_WARNING"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  actions_enabled     = true
  alarm_description   = "RDS CPU Utilization >= 75% for 3/5 datapoints."

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

# CloudWatch Metric Alarms (CPU Utilization - Critical)
resource "aws_cloudwatch_metric_alarm" "metric_alarms_critical" {
  for_each = var.databases

  alarm_name          = "${each.value.project_name}_RDS_CPU_UTILIZATION_CRITICAL"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  actions_enabled     = true
  alarm_description   = "RDS CPU Utilization >= 90% for 2/3 datapoints."

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
