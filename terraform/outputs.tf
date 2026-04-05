output "server_ip" {
  description = "Public IP of the K8s server node"
  value       = aws_instance.k8s_server.public_ip
}

output "agent_ips" {
  description = "Public IPs of the K8s agent nodes"
  value       = aws_instance.k8s_agent[*].public_ip
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "ID of the K8s nodes security group"
  value       = aws_security_group.k8s_nodes.id
}