# VPC Peering Connection between Production and Staging

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

# Data sources to get VPC information
data "aws_vpc" "production" {
  filter {
    name   = "tag:Name"
    values = ["cafe-aroma-production-vpc"]
  }
}

data "aws_vpc" "staging" {
  filter {
    name   = "tag:Name"
    values = ["cafe-aroma-staging-vpc"]
  }
}

# Get route tables
data "aws_route_tables" "production" {
  vpc_id = data.aws_vpc.production.id
}

data "aws_route_tables" "staging" {
  vpc_id = data.aws_vpc.staging.id
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "prod_to_staging" {
  peer_vpc_id = data.aws_vpc.staging.id
  vpc_id      = data.aws_vpc.production.id
  auto_accept = true

  tags = {
    Name = "cafe-aroma-prod-staging-peering"
  }
}

# Route from Production to Staging
resource "aws_route" "prod_to_staging" {
  count = length(data.aws_route_tables.production.ids)

  route_table_id            = data.aws_route_tables.production.ids[count.index]
  destination_cidr_block    = "10.1.0.0/16"  # Staging VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_to_staging.id
}

# Route from Staging to Production
resource "aws_route" "staging_to_prod" {
  count = length(data.aws_route_tables.staging.ids)

  route_table_id            = data.aws_route_tables.staging.ids[count.index]
  destination_cidr_block    = "10.0.0.0/16"  # Production VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_to_staging.id
}