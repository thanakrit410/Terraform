provider "aws" {
  region     = "ap-southeast-1"
  access_key = "Cxxxxxxxxxxxxxxx"
  secret_key = "Dxxxxxxxxxxxxxxx"
}

# 1. สร้าง Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "EC2-key"
  public_key = file("C:/Users/10097619/.ssh/id_ed25519.pub")
}

# 2. สร้าง IAM Role สำหรับ SSM
resource "aws_iam_role" "ssm_role" {
  name = "SSMRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 3. Attach Policy ที่จำเป็นให้ IAM Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.ssm_role.name
  policy_arn = var.policy_arns[count.index]
}

variable "policy_arns" {
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess",
    "arn:aws:iam::aws:policy/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]
}

# 4. สร้าง Instance Profile เชื่อมกับ IAM Role
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

# 5. สร้าง EC2 Instance
resource "aws_instance" "my_ec2" {
  ami                  = "ami-07c9c7aaab42cba5a" # Amazon Linux 2
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  subnet_id            = "subnet-079402f92f74c8fe1"

  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = ["sg-02982a1e1f10f8a92"]
  associate_public_ip_address = true

  tags = {
    Name = "My-Terraform-EC2"
  }
}

# 6. Output EC2 Instance ID
output "aws_instance_id" {
  value = aws_instance.my_ec2.id
}
