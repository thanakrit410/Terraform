provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxxxxxx"
}


variable "services" {
  default = {
    service1 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-admin-svc-ecs-service"
    },
    service2 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-auth-svc-ecs-service"
    },
    service3 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-br-frontend-svc-ecs-service"
    },
    service4 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-car-svc-ecs-service"
    },
    service5 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-crm-svc-ecs-service"
    },
    service6 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-hq-frontend-svc-ecs-service"
    },
    service7 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-hq-svc-ecs-service"
    },
    service8 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-interface-svc-ecs-service"
    },
    service9 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-pm-svc-ecs-service"
    },
    service10 = {
      ClusterName  = "PRD-tss-ecs-cluster"
      project_name = "PRD-tss-pos-svc-ecs-service"
    }
  }
}

locals {
  sns_topics = flatten([
    for service_key, service in var.services : [
      for alarm_type in ["WARNING", "CRITICAL", "NORMAL"] : {
        key          = "${service_key}_${alarm_type}"
        service_key  = service_key
        alarm_type   = alarm_type
        project_name = service.project_name
      }
    ]
  ])
}

# SNS Topics
resource "aws_sns_topic" "sns_topics" {
  for_each = { for topic in local.sns_topics : topic.key => topic }

  name = "${each.value.project_name}_ECS_CPU_UTILIZATION_${each.value.alarm_type}"

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


resource "aws_cloudwatch_metric_alarm" "metric_alarms" {
  for_each = var.services

  alarm_name          = "${each.value.project_name}/CPU_UTILIZATION_WARNING"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  actions_enabled     = true
  alarm_description   = "ECS CPU Utilization >= 75% for 3/5 datapoints."

  dimensions = {
    ClusterName = each.value.ClusterName
    ServiceName = each.value.project_name
  }

  alarm_actions = [
    aws_sns_topic.sns_topics["${each.key}_${upper("warning")}"].arn
  ]

  ok_actions = [
    aws_sns_topic.sns_topics["${each.key}_${upper("normal")}"].arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "Truck-Service"
    map-migrated = "migODJ2EO9APK"
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_alarms_critical" {
  for_each = var.services

  alarm_name          = "${each.value.project_name}/CPU_UTILIZATION_CRITICAL"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  actions_enabled     = true
  alarm_description   = "ECS CPU Utilization >= 90% for 2/3 datapoints."

  dimensions = {
    ClusterName = each.value.ClusterName
    ServiceName = each.value.project_name
  }

  alarm_actions = [
    aws_sns_topic.sns_topics["${each.key}_${upper("critical")}"].arn
  ]

  tags = {
    Environment  = "PRD"
    Project      = "Truck-Service"
    map-migrated = "migODJ2EO9APK"
  }
}
