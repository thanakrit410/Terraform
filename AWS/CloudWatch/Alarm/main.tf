provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name = "HighCPUUtilization"

}