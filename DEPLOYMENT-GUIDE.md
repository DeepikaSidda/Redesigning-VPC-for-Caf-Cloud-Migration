# 🚀 Café Aroma VPC Deployment Guide

## 📋 Pre-Deployment Checklist

### 1. **AWS Account Setup**
- [ ] AWS Account with appropriate permissions
- [ ] AWS CLI installed and configured
- [ ] EC2 Key Pair created in target region

### 2. **Local Environment**
- [ ] Terraform installed (v1.0+)
- [ ] Git installed
- [ ] Text editor (VS Code recommended)

### 3. **Network Information**
- [ ] Your public IP address (from whatismyip.com)
- [ ] Target AWS region selected
- [ ] Key pair name noted

## 🛠️ Step-by-Step Deployment

### Step 1: Environment Preparation
```bash
# Clone or download the project
cd VPC-Month

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration with your values
notepad terraform.tfvars  # Windows
# or
nano terraform.tfvars     # Linux/Mac
```

### Step 2: Configure Variables
Edit `terraform.tfvars` with your specific values:
```hcl
# AWS Configuration
aws_region = "us-east-1"

# Project Configuration  
project_name = "cafe-aroma"
environment  = "production"

# Network Configuration (use defaults or customize)
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# EC2 Configuration
instance_type = "t3.micro"
key_pair_name = "your-existing-keypair"  # MUST exist in AWS

# Security Configuration
your_ip_address = "203.0.113.0/32"  # Replace with YOUR actual IP
```

### Step 3: Initialize Terraform
```bash
# Initialize Terraform (downloads providers)
terraform init

# Validate configuration
terraform validate

# Format code (optional)
terraform fmt
```

### Step 4: Plan Deployment
```bash
# Create execution plan
terraform plan

# Review the plan carefully
# Should show ~30-40 resources to be created
```

### Step 5: Deploy Infrastructure
```bash
# Apply configuration
terraform apply

# Type 'yes' when prompted
# Deployment takes ~5-10 minutes
```

### Step 6: Verify Deployment
```bash
# Run validation script
chmod +x scripts/validate-infrastructure.sh
./scripts/validate-infrastructure.sh

# Check outputs
terraform output

# Test web servers
curl http://$(terraform output -raw load_balancer_dns_name)
```

## 🔧 Post-Deployment Configuration

### 1. **Test SSH Access**
```bash
# Get web server IP
WEB_IP=$(terraform output -raw web_server_public_ips | jq -r '.[0]')

# SSH to web server (bastion)
ssh -i your-key.pem ec2-user@$WEB_IP

# From web server, SSH to app server
APP_IP=$(terraform output -raw app_server_private_ips | jq -r '.[0]')
ssh ec2-user@$APP_IP
```

### 2. **Verify Load Balancer**
```bash
# Get load balancer DNS
ALB_DNS=$(terraform output -raw load_balancer_dns_name)

# Test load balancer (may take 2-3 minutes to be ready)
curl http://$ALB_DNS

# Test multiple times to see load balancing
for i in {1..5}; do curl -s http://$ALB_DNS | grep "Instance ID"; done
```

### 3. **Check Monitoring**
```bash
# View VPC Flow Logs (after 5-10 minutes)
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"

# Check CloudWatch dashboard
echo "Dashboard URL: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:"
```

## 🎯 Testing Scenarios

### Scenario 1: Web Application Access
```bash
# Test public web access
curl -I http://$(terraform output -raw load_balancer_dns_name)
# Expected: HTTP 200 OK

# Test direct web server access
curl -I http://$(terraform output -raw web_server_public_ips | jq -r '.[0]')
# Expected: HTTP 200 OK
```

### Scenario 2: Security Validation
```bash
# Try to access app server directly (should fail)
APP_IP=$(terraform output -raw app_server_private_ips | jq -r '.[0]')
curl --connect-timeout 5 http://$APP_IP:8080
# Expected: Connection timeout (no direct access)

# SSH to web server, then test app server
ssh -i your-key.pem ec2-user@$(terraform output -raw web_server_public_ips | jq -r '.[0]')
curl http://10.0.3.x:8080  # Use actual private IP
# Expected: JSON response from app server
```

### Scenario 3: High Availability
```bash
# Test both web servers
terraform output -json web_server_public_ips | jq -r '.[]' | while read ip; do
  echo "Testing $ip:"
  curl -s http://$ip | grep "Instance ID"
done
# Expected: Different instance IDs
```

## 🚨 Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: "Key pair not found"
**Error:** `InvalidKeyPair.NotFound`
**Solution:**
```bash
# Create key pair in AWS Console or CLI
aws ec2 create-key-pair --key-name your-keypair --query 'KeyMaterial' --output text > your-keypair.pem
chmod 400 your-keypair.pem
```

#### Issue 2: "SSH connection refused"
**Error:** `Connection refused` when SSH to web server
**Solution:**
1. Check security group allows SSH from your IP
2. Verify your IP address in terraform.tfvars
3. Wait 2-3 minutes for instance to fully boot

#### Issue 3: "Load balancer not responding"
**Error:** Load balancer returns 503 or timeouts
**Solution:**
1. Wait 2-3 minutes for health checks to pass
2. Check target group health in AWS Console
3. Verify web servers are running: `systemctl status httpd`

#### Issue 4: "Private instances can't reach internet"
**Error:** App servers can't download updates
**Solution:**
1. Verify NAT Gateway is created and running
2. Check private route table has route to NAT Gateway
3. Confirm security groups allow outbound traffic

### Debug Commands
```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# Check AWS resources
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)
aws ec2 describe-instances --filters "Name=tag:Project,Values=cafe-aroma"
aws elbv2 describe-load-balancers --names cafe-aroma-production-alb

# Check logs
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"
```

## 📊 Monitoring and Maintenance

### Daily Checks
- [ ] Load balancer health checks passing
- [ ] All instances running
- [ ] No security alerts in VPC Flow Logs

### Weekly Checks
- [ ] Review VPC Flow Logs for anomalies
- [ ] Check CloudWatch metrics
- [ ] Verify backup processes (if implemented)

### Monthly Checks
- [ ] Security group audit
- [ ] Cost optimization review
- [ ] Update AMIs and patches

## 💰 Cost Management

### Expected Monthly Costs (us-east-1)
- **EC2 Instances (4x t3.micro)**: ~$15/month
- **NAT Gateway**: ~$45/month
- **Load Balancer**: ~$20/month
- **VPC Flow Logs**: ~$10/month
- **Data Transfer**: ~$5/month
- **Total**: ~$95/month

### Cost Optimization Tips
1. Use t3.micro for development/testing
2. Consider single AZ for non-production
3. Implement auto-scaling to optimize usage
4. Use VPC endpoints to reduce NAT Gateway costs
5. Regular cleanup of unused resources

## 🔄 Scaling and Evolution

### Horizontal Scaling
```bash
# Add more instances to existing subnets
# Modify variables.tf to increase instance count
# Apply changes: terraform apply
```

### Vertical Scaling
```bash
# Change instance types
# Update instance_type in terraform.tfvars
# Apply changes: terraform apply
```

### Adding New Environments
```bash
# Use environment-specific configurations
cd environments/staging
terraform init
terraform apply
```

## 🧹 Cleanup Process

### Complete Infrastructure Removal
```bash
# Run cleanup script
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh

# Or manual cleanup
terraform destroy
# Type 'yes' when prompted
```

### Partial Cleanup (Keep VPC, Remove Instances)
```bash
# Comment out compute module in main.tf
# terraform apply
```

## 📞 Support and Resources

### Documentation
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Troubleshooting Resources
1. Check `validation-report.txt` after running validation script
2. Review Terraform logs: `terraform apply -debug`
3. AWS CloudTrail for API call history
4. VPC Flow Logs for network troubleshooting

### Next Steps
1. Implement auto-scaling groups
2. Add RDS database with Multi-AZ
3. Implement CI/CD pipeline
4. Add monitoring and alerting
5. Implement backup and disaster recovery

---

**🎉 Congratulations!** You've successfully deployed a production-ready, secure, and scalable VPC architecture for Café Aroma!