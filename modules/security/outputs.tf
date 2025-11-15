output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "public_nacl_id" {
  description = "ID of the public network ACL"
  value       = aws_network_acl.public.id
}

output "private_nacl_id" {
  description = "ID of the private network ACL"
  value       = aws_network_acl.private.id
}