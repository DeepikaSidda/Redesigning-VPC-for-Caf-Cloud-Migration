output "peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.prod_to_staging.id
}

output "peering_connection_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection.prod_to_staging.accept_status
}

output "production_vpc_id" {
  description = "Production VPC ID"
  value       = data.aws_vpc.production.id
}

output "staging_vpc_id" {
  description = "Staging VPC ID"
  value       = data.aws_vpc.staging.id
}