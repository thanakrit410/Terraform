provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxx"
}

# ตัวแปรสำหรับ Instances และ SNS Topics
variable "instances" {
  default = {
    instance1 = {
      project_name  = "PRD_LSRETAIL_BATCH_EC2"
      instance_id   = "i-0b2b4a21e77248450"
      instance_type = "c6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance2 = {
      project_name  = "PRD_LSRETAIL_INF_AZ1A_EC2"
      instance_id   = "i-004f56ae4ff807d51"
      instance_type = "c6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance3 = {
      project_name  = "PRD_LSRETAIL_INF_AZ1B_EC2"
      instance_id   = "i-0066d833916eb5258"
      instance_type = "c6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance4 = {
      project_name  = "PRD_LSRETAIL_HQ_AZ1A_EC2"
      instance_id   = "i-014a24c541a307fed"
      instance_type = "m6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance5 = {
      project_name  = "PRD_LSRETAIL_HQ_AZ1B_EC2"
      instance_id   = "i-073154cc4f68df32b"
      instance_type = "m6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance6 = {
      project_name  = "PRD_LSRETAIL_OMNI_AZ1A_EC2"
      instance_id   = "i-0bf99eff4be614d21"
      instance_type = "m6i.xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance7 = {
      project_name  = "PRD_LSRETAIL_OMNI_AZ1B_EC2"
      instance_id   = "i-0c0f5967fa0bc8422"
      instance_type = "m6i.xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance8 = {
      project_name  = "PRD_LSRETAIL_REPORTING_DB_EC2"
      instance_id   = "i-01b4312ea55113707"
      instance_type = "m6i.4xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
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

  name = "${each.value.project_name}_LOGICAL_DISK02_FREE_SPACE_${each.value.alarm_type}"

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

  alarm_name          = "${each.value.project_name}_LOGICAL_DISK02_FREE_SPACE_WARNING"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "LogicalDisk % Free Space"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 10
  actions_enabled     = true
  alarm_description   = "EC2 LogicalDisk % Free Space <= 10% for 2/3 datapoints."

  dimensions = {
    InstanceId   = each.value.instance_id
    ImageId      = each.value.ami
    objectname   = "LogicalDisk"
    InstanceType = each.value.instance_type
    instance     = "D:"
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

  alarm_name          = "${each.value.project_name}_LOGICAL_DISK02_FREE_SPACE_CRITICAL"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "LogicalDisk % Free Space"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  actions_enabled     = true
  alarm_description   = "EC2 LogicalDisk % Free Space <= 5% for 2/3 datapoints."

  dimensions = {
    InstanceId   = each.value.instance_id
    ImageId      = each.value.ami
    objectname   = "LogicalDisk"
    InstanceType = each.value.instance_type
    instance     = "D:"
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
