#!/bin/bash

# Café Aroma VPC Infrastructure Cleanup Script
# This script safely destroys the infrastructure

set -e

echo "🧹 Café Aroma VPC Infrastructure Cleanup"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  WARNING: This will destroy all infrastructure!${NC}"
echo "This includes:"
echo "- VPC and all subnets"
echo "- EC2 instances"
echo "- Load balancer"
echo "- Security groups"
echo "- NAT Gateway and Elastic IP"
echo "- VPC Flow Logs"
echo ""

read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${GREEN}✅ Cleanup cancelled${NC}"
    exit 0
fi

echo ""
echo "🔍 Checking current infrastructure..."

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠️  No terraform.tfstate found. Nothing to destroy.${NC}"
    exit 0
fi

# Show what will be destroyed
echo "📋 Planning destruction..."
terraform plan -destroy

echo ""
read -p "Proceed with destruction? (type 'DESTROY' to confirm): " final_confirm

if [ "$final_confirm" != "DESTROY" ]; then
    echo -e "${GREEN}✅ Cleanup cancelled${NC}"
    exit 0
fi

echo ""
echo "🚀 Starting infrastructure destruction..."

# Destroy infrastructure
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Infrastructure destroyed successfully${NC}"
    
    # Clean up local files
    echo "🧹 Cleaning up local files..."
    
    # Remove terraform files (optional)
    read -p "Remove terraform state files? (y/n): " remove_state
    if [ "$remove_state" = "y" ]; then
        rm -f terraform.tfstate*
        rm -f .terraform.lock.hcl
        rm -rf .terraform/
        echo -e "${GREEN}✅ Terraform state files removed${NC}"
    fi
    
    # Remove validation report
    if [ -f "validation-report.txt" ]; then
        rm -f validation-report.txt
        echo -e "${GREEN}✅ Validation report removed${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
    echo ""
    echo "💡 What was cleaned up:"
    echo "- All AWS resources destroyed"
    echo "- Local state files removed (if selected)"
    echo "- Validation reports removed"
    echo ""
    echo "📝 Note: Your terraform.tfvars file is preserved for future use"
    
else
    echo -e "${RED}❌ Infrastructure destruction failed${NC}"
    echo "Please check the error messages above and try again"
    exit 1
fi