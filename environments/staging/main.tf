# Staging Environment Configuration
# Smaller, cost-optimized version for testing

terraform {
  required_version = ">= 1.0"
}

# Use the root module with staging-specific configuration
module "cafe_aroma_vpc_staging" {
  source = "../../"
  
  # Staging-specific variables
  aws_region   = "us-east-1"
  project_name = "cafe-aroma"
  environment  = "staging"
  
  # Staging network configuration (smaller CIDR)
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  
  # Staging instance configuration (smaller instances)
  instance_type = "t3.micro"  # Free tier eligible
  
  # Security configuration
  key_pair_name   = var.key_pair_name
  your_ip_address = var.your_ip_address
}