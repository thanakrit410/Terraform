provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true  
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "subnet_az1" {
  vpc_id                  = aws_vpc.my_vpc.id      
  cidr_block              = "10.0.0.0/20"         
  availability_zone       = "ap-southeast-1a"      
  map_public_ip_on_launch = true                   
  tags = {
    Name = "Subnet-AZ1"
  }
}

resource "aws_subnet" "subnet_az2" {
  vpc_id                  = aws_vpc.my_vpc.id      
  cidr_block              = "10.0.16.0/20"         
  availability_zone       = "ap-southeast-1b"     
  map_public_ip_on_launch = true                  
  tags = {
    Name = "Subnet-AZ2"
  }
}

resource "aws_subnet" "subnet_az3" {
  vpc_id                  = aws_vpc.my_vpc.id     
  cidr_block              = "10.0.32.0/20"         
  availability_zone       = "ap-southeast-1c"     
  map_public_ip_on_launch = true                   
  tags = {
    Name = "Subnet-AZ3"
  }
}


output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_az1_id" {
  value = aws_subnet.subnet_az1.id
}

output "subnet_az2_id" {
  value = aws_subnet.subnet_az2.id
}

output "subnet_az3_id" {
  value = aws_subnet.subnet_az3.id
}