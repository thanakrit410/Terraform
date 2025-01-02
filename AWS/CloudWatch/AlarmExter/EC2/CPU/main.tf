provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxx"
}

# ตัวแปรสำหรับ Instances และ SNS Topics
variable "instances" {
  default = {
    instance1 = {
      instance_id  = "i-0dc8b9c4b8ff605d0"
      project_name = "PRD_LSRETAIL_INF_STBYDB_EC2"
    }
    instance2 = {
      instance_id  = "i-088563c1868c94188"
      project_name = "PRD_LSRETAIL_HQ_STBYDB_EC2"
    }
    instance3 = {
      instance_id  = "i-01c07c9a73a3bf7d2"
      project_name = "PRD_LSRETAIL_STAGING_STBYDB_EC2"
    }
    instance4 = {
      instance_id  = "i-0066d833916eb5258"
      project_name = "PRD_LSRETAIL_INF_AZ1B_EC2"
    }
    instance5 = {
      instance_id  = "i-073154cc4f68df32b"
      project_name = "PRD_LSRETAIL_HQ_AZ1B_EC2"
    }
    instance6 = {
      instance_id  = "i-0c0f5967fa0bc8422"
      project_name = "PRD_LSRETAIL_OMNI_AZ1B_EC2"
    }
    instance7 = {
      instance_id  = "i-0b12f5e5a01102ef8"
      project_name = "PRD_LSRETAIL_INF_MASTER_EC2"
    }
    instance8 = {
      instance_id  = "i-033d045c1b01bb2ec"
      project_name = "PRD_LSRETAIL_HQ_MASTER_EC2"
    }
    instance9 = {
      instance_id  = "i-03fc7d38e0d6b5f65"
      project_name = "PRD_LSRETAIL_OMNI_MASTER_EC2"
    }
  }
}

locals {
  sns_topics = flatten([
    for instance_key, instance in var.instances : [
      for alarm_type in ["WARNING", "CRITICAL", "NORMAL"] : {
        key          = "${instance_key}_${alarm_type}"
        instance_key = instance_key
        alarm_type   = alarm_type
        project_name = instance.project_name
      }
    ]
  ])
}

# SNS Topics
resource "aws_sns_topic" "sns_topics" {
  for_each = { for topic in local.sns_topics : topic.key => topic }

  name = "${each.value.project_name}_CPU_UTILIZATION_${each.value.alarm_type}"

  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
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

# CloudWatch Metric Alarms
resource "aws_cloudwatch_metric_alarm" "metric_alarms" {
  for_each = var.instances

  alarm_name          = "${each.value.project_name}_CPU_UTILIZATION_WARNING"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  actions_enabled     = true
  alarm_description   = "EC2 CPU Utilization >= 75% for 3/5 datapoints."

  dimensions = {
    InstanceId = each.value.instance_id
  }

  alarm_actions = [
    aws_sns_topic.sns_topics["${each.key}_${upper("warning")}"].arn
  ]

  ok_actions = [
    aws_sns_topic.sns_topics["${each.key}_${upper("normal")}"].arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }
}

# Alarms for Critical State
resource "aws_cloudwatch_metric_alarm" "metric_alarms_critical" {
  for_each = var.instances

  alarm_name          = "${each.value.project_name}_CPU_UTILIZATION_CRITICAL"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  actions_enabled     = true
  alarm_description   = "EC2 CPU Utilization >= 90% for 2/3 datapoints."

  dimensions = {
    InstanceId = each.value.instance_id
  }

  alarm_actions = [
    aws_sns_topic.sns_topics["${each.key}_${upper("critical")}"].arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }
}
