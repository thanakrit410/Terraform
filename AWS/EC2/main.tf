provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "EC2-key"
  public_key = file("C:/Users/10097619/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_on_ec2"

  vpc_id = "vpc-0eb5cfc403f2ba9c3" 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-047126e50991d067b"
  instance_type = "t2.micro"    
  subnet_id = "subnet-0609144b5e0e46a75"        

  key_name          = aws_key_pair.my_key.key_name
#   security_groups   = [aws_security_group.allow_ssh.name]
  associate_public_ip_address = true

  tags = {
    Name = "My-Terraform-EC2" #  Name for EC2 **
  }
}