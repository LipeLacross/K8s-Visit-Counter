variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "k8s-visit-counter"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu 22.04)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "server_instance_type" {
  description = "Instance type for K8s server node"
  type        = string
  default     = "t3.medium"
}

variable "agent_instance_type" {
  description = "Instance type for K8s agent nodes"
  type        = string
  default     = "t3.small"
}

variable "agent_count" {
  description = "Number of agent nodes"
  type        = number
  default     = 2
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = ""
}