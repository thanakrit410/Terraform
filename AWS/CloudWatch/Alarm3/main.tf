provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxx"
}

resource "aws_cloudwatch_metric_alarm" "cpu_warning" {
  alarm_name          = "PRD_LSRETAIL_BATCH_EC2_CPU_UTILIZATION_WARNING"
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
    InstanceId = "i-0b2b4a21e77248450"
  }

  alarm_actions = [
    aws_sns_topic.my_sns_topic_1.arn
  ]


  ok_actions = [
    aws_sns_topic.my_sns_topic_3.arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }

}

resource "aws_cloudwatch_metric_alarm" "cpu_critical" {
  alarm_name          = "PRD_LSRETAIL_BATCH_EC2_CPU_UTILIZATION_CRITICAL"
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
    InstanceId = "i-0b2b4a21e77248450"
  }

  alarm_actions = [
    aws_sns_topic.my_sns_topic_3.arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }


}

resource "aws_sns_topic" "my_sns_topic_1" {
  name = "PRD_LSRETAIL_BATCH_EC2_CPU_UTILIZATION_WARNING"
  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }
}

resource "aws_sns_topic" "my_sns_topic_2" {
  name = "PRD_LSRETAIL_BATCH_EC2_CPU_UTILIZATION_NORMAL"
  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }
}

resource "aws_sns_topic" "my_sns_topic_3" {
  name = "PRD_LSRETAIL_BATCH_EC2_CPU_UTILIZATION_CRITICAL"
  tags = {
    Environment  = "PRD"
    Project      = "LS-Retail"
    map-migrated = "migODJ2EO9APK"
  }
}



resource "aws_sns_topic_subscription" "email_subscription_1" {
  topic_arn = aws_sns_topic.my_sns_topic_1.arn
  protocol  = "email"
  endpoint  = "aws@pt.co.th"
}

resource "aws_sns_topic_subscription" "email_subscription_2" {
  topic_arn = aws_sns_topic.my_sns_topic_2.arn
  protocol  = "email"
  endpoint  = "aws@pt.co.th"
}

resource "aws_sns_topic_subscription" "email_subscription_3" {
  topic_arn = aws_sns_topic.my_sns_topic_3.arn
  protocol  = "email"
  endpoint  = "aws@pt.co.th"
}
