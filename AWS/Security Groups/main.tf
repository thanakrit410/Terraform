provider "aws" {
  region = "ap-southeast-1"
  access_key = "Cxxxxxxxxxxxxxxx"
  secret_key = "Dxxxxxxxxxxxxxxx"
}

resource "aws_security_group" "deno" {
  name        = "demo-security-group"
  description = "Allow SSH traffic"
  vpc_id      = "vpc-08559b1b209721973"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
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

output "security_group_id" {
  value = aws_security_group.deno.id
}
