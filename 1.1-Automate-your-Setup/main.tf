# Provision Ubuntu VM  on default VPC with a key pair for SSH access
# A setup script would be run on the VM to install some packages

# Setup the provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

  }
}

provider "aws" {
  region = "us-west-2"
}

# Query the Ubuntu AMI to be used 
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create the Lab VM
resource "aws_instance" "lab" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  subnet_id              = aws_subnet.lab_subnet.id

  associate_public_ip_address = true

  key_name = aws_key_pair.lab_key_pair.key_name

  root_block_device {
    volume_size           = 30 # Change from 8GB default to 30GB
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "Cloudlab VM"
  }
}

# Create an AWS Key pair for the VM
resource "aws_key_pair" "lab_key_pair" {
  key_name   = "lab_key_pair"
  public_key = tls_private_key.lab_key_pair.public_key_openssh
}


# Create the private key
resource "tls_private_key" "lab_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


# Create a VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Cloudlab VPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Cloudlab IGW"
  }
}

# Create a Subnet
resource "aws_subnet" "lab_subnet" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Cloudlab Subnet"
  }
}

# Create a Route Table
resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "Cloudlab Route Table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "lab_route_table_assoc" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}

# Create a Security Group
resource "aws_security_group" "lab_sg" {
  name        = "lab_sg"
  description = "Security group for lab"
  vpc_id      = aws_vpc.lab_vpc.id

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

  tags = {
    Name = "Cloudlab Security Group"
  }
}

