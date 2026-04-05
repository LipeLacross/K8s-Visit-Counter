terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support  = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "k8s_nodes" {
  name        = "${var.project_name}-k8s-nodes-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-k8s-nodes-sg"
  }
}

resource "aws_key_pair" "k8s" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key
  
  tags = {
    Name = "${var.project_name}-key"
  }
}

resource "aws_instance" "k8s_server" {
  ami           = var.ami_id
  instance_type = var.server_instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = aws_key_pair.k8s.key_name
  security_groups = [aws_security_group.k8s_nodes.id]
  
  tags = {
    Name = "${var.project_name}-server"
  }
}

resource "aws_instance" "k8s_agent" {
  count        = var.agent_count
  ami          = var.ami_id
  instance_type = var.agent_instance_type
  subnet_id    = aws_subnet.public[count.index].id
  key_name     = aws_key_pair.k8s.key_name
  security_groups = [aws_security_group.k8s_nodes.id]
  
  tags = {
    Name = "${var.project_name}-agent-${count.index + 1}"
  }
}

output "server_public_ip" {
  value = aws_instance.k8s_server.public_ip
}

output "agent_public_ips" {
  value = aws_instance.k8s_agent[*].public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}