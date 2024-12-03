provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Axxxxxxxxxxxxxxx"
  secret_key = "Bxxxxxxxxxxxxxxx"
}

# ตัวแปรสำหรับ Instances และ SNS Topics
variable "instances" {
  default = {
    instance1 = {
      project_name  = "PRD_LSRETAIL_INF_ACTVDB_EC2"
      instance_id   = "i-0fb290b45a524cf8c"
      instance_type = "m6i.4xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance2 = {
      project_name  = "PRD_LSRETAIL_HQ_ACTVDB_EC2"
      instance_id   = "i-0085a6ddc59450e30"
      instance_type = "m6i.4xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance3 = {
      project_name  = "PRD_LSRETAIL_STAGING_ATCVDB_EC2"
      instance_id   = "i-0a8c253494cccb050"
      instance_type = "r6i.2xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance4 = {
      project_name  = "PRD_LSRETAIL_BATCH_EC2"
      instance_id   = "i-0b2b4a21e77248450"
      instance_type = "c6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance5 = {
      project_name  = "PRD_LSRETAIL_OMNI_ACTVDB_EC2"
      instance_id   = "i-03d3b167badb6a44b"
      instance_type = "m6i.2xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance6 = {
      project_name  = "PRD_LSRETAIL_INF_AZ1A_EC2"
      instance_id   = "i-004f56ae4ff807d51"
      instance_type = "c6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance7 = {
      project_name  = "PRD_LSRETAIL_HQ_AZ1A_EC2"
      instance_id   = "i-014a24c541a307fed"
      instance_type = "m6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance8 = {
      project_name  = "PRD_LSRETAIL_REPORTING_DB_EC2"
      instance_id   = "i-01b4312ea55113707"
      instance_type = "m6i.4xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance9 = {
      project_name  = "PRD_LSRETAIL_OMNI_AZ1A_EC2"
      instance_id   = "i-0bf99eff4be614d21"
      instance_type = "m6i.xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance10 = {
      project_name  = "PRD_LSRETAIL_OMNI_STBYDB_EC2"
      instance_id   = "i-0e57a9e141e67d002"
      instance_type = "m6i.2xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance11 = {
      project_name  = "PRD_LSRETAIL_INF_STBYDB_EC2"
      instance_id   = "i-0dc8b9c4b8ff605d0"
      instance_type = "m6i.4xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance12 = {
      project_name  = "PRD_LSRETAIL_HQ_STBYDB_EC2"
      instance_id   = "i-088563c1868c94188"
      instance_type = "m6i.4xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance13 = {
      project_name  = "PRD_LSRETAIL_STAGING_STBYDB_EC2"
      instance_id   = "i-01c07c9a73a3bf7d2"
      instance_type = "r6i.2xlarge"
      ami           = "ami-07f20fba5f06fa8f5"
    },
    instance14 = {
      project_name  = "PRD_LSRETAIL_INF_AZ1B_EC2"
      instance_id   = "i-0066d833916eb5258"
      instance_type = "c6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance15 = {
      project_name  = "PRD_LSRETAIL_HQ_AZ1B_EC2"
      instance_id   = "i-073154cc4f68df32b"
      instance_type = "m6i.2xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance16 = {
      project_name  = "PRD_LSRETAIL_OMNI_AZ1B_EC2"
      instance_id   = "i-0c0f5967fa0bc8422"
      instance_type = "m6i.xlarge"
      ami           = "ami-00cefb167fda388d1"
    },
    instance17 = {
      project_name  = "PRD_LSRETAIL_INF_MASTER_EC2"
      instance_id   = "i-0b12f5e5a01102ef8"
      instance_type = "t3.medium"
      ami           = "ami-00cefb167fda388d1"
    },
    instance18 = {
      project_name  = "PRD_LSRETAIL_HQ_MASTER_EC2"
      instance_id   = "i-033d045c1b01bb2ec"
      instance_type = "t3.medium"
      ami           = "ami-00cefb167fda388d1"
    },
    instance19 = {
      project_name  = "PRD_LSRETAIL_OMNI_MASTER_EC2"
      instance_id   = "i-03fc7d38e0d6b5f65"
      instance_type = "t3.medium"
      ami           = "ami-00cefb167fda388d1"
    }
  }

}

data "aws_cloudwatch_metric_data" "logical_disks" {
  for_each = var.instances

  namespace   = "CWAgent"
  metric_name = "LogicalDisk % Free Space"
  dimensions = {
    InstanceId = each.value.instance_id
    objectname = "LogicalDisk"
  }
}

output "logical_disk_metrics" {
  value = {
    for instance_key, instance_data in var.instances :
    instance_key => {
      instance_id = instance_data.instance_id
      metric_name = data.aws_cloudwatch_metric.logical_disks[instance_key].metric_name
    }
  }
}



