# Production Environment Configuration
# This is an example of environment-specific configuration

terraform {
  required_version = ">= 1.0"
  
  # Uncomment and configure for production state management
  # backend "s3" {
  #   bucket = "cafe-aroma-terraform-state"
  #   key    = "production/terraform.tfstate"
  #   region = "us-east-1"
  #   encrypt = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Use the root module
module "cafe_aroma_vpc" {
  source = "../../"
  
  # Production-specific variables
  aws_region   = "us-east-1"
  project_name = "cafe-aroma"
  environment  = "production"
  
  # Production network configuration
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  
  # Production instance configuration
  instance_type = "t3.small"  # Larger than dev/staging
  
  # Security configuration
  key_pair_name   = var.key_pair_name
  your_ip_address = var.your_ip_address
}

# Production-specific resources
resource "aws_s3_bucket" "backups" {
  bucket = "${module.cafe_aroma_vpc.project_name}-${module.cafe_aroma_vpc.environment}-backups"
  
  tags = {
    Environment = "production"
    Purpose     = "Backups"
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "backups" {
  bucket = aws_s3_bucket.backups.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}