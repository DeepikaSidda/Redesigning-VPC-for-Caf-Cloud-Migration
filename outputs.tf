# Output Values for Café Aroma VPC Project

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnet Information
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Gateway Information
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

# Security Group Information
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.security.web_security_group_id
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = module.security.app_security_group_id
}

# EC2 Instance Information
output "web_instance_ids" {
  description = "IDs of web server instances"
  value       = module.compute.web_instance_ids
}

output "app_instance_ids" {
  description = "IDs of app server instances"
  value       = module.compute.app_instance_ids
}

output "web_server_public_ips" {
  description = "Public IP addresses of web servers"
  value       = module.compute.web_server_public_ips
}

output "web_server_private_ips" {
  description = "Private IP addresses of web servers"
  value       = module.compute.web_server_private_ips
}

output "app_server_private_ips" {
  description = "Private IP addresses of app servers"
  value       = module.compute.app_server_private_ips
}

# Load Balancer Information
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.load_balancer.load_balancer_zone_id
}

# Monitoring Information
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = module.monitoring.vpc_flow_log_id
}

# Connection Information
output "ssh_connection_commands" {
  description = "SSH commands to connect to instances"
  value = {
    web_server_1 = "ssh -i ${var.key_pair_name}.pem ec2-user@${module.compute.web_server_public_ips[0]}"
    web_server_2 = "ssh -i ${var.key_pair_name}.pem ec2-user@${module.compute.web_server_public_ips[1]}"
    app_servers  = "First SSH to web server, then: ssh ec2-user@${join(" or ssh ec2-user@", module.compute.app_server_private_ips)}"
  }
}

# Testing URLs
output "testing_urls" {
  description = "URLs for testing the infrastructure"
  value = {
    load_balancer = "http://${module.load_balancer.load_balancer_dns_name}"
    web_server_1  = "http://${module.compute.web_server_public_ips[0]}"
    web_server_2  = "http://${module.compute.web_server_public_ips[1]}"
  }
}