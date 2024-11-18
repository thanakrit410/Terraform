provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_security_group" "deno" {
  name        = "demo-security-group"
  description = "Allow SSH traffic"
  vpc_id      = "vpc-xxxxxxxx"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security-Group"
  }
}
