output "web_instance_ids" {
  description = "IDs of web server instances"
  value       = aws_instance.web[*].id
}

output "app_instance_ids" {
  description = "IDs of app server instances"
  value       = aws_instance.app[*].id
}

output "web_server_public_ips" {
  description = "Public IP addresses of web servers"
  value       = aws_instance.web[*].public_ip
}

output "web_server_private_ips" {
  description = "Private IP addresses of web servers"
  value       = aws_instance.web[*].private_ip
}

output "app_server_private_ips" {
  description = "Private IP addresses of app servers"
  value       = aws_instance.app[*].private_ip
}