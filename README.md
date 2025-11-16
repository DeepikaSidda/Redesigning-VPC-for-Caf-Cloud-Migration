# Café Aroma VPC Redesign Project

## 🏗️ Project Overview

This project redesigns Café Aroma's AWS VPC infrastructure from a poorly configured default setup to a production-ready, secure, and scalable multi-tier architecture using Infrastructure as Code (Terraform).

## 🎯 Architecture Highlights

- **Multi-AZ Design**: Resources distributed across 2 Availability Zones for high availability
- **Layered Security**: Public/Private subnet separation with security groups and NACLs
- **Modular Infrastructure**: Reusable Terraform modules for easy maintenance
- **Monitoring Ready**: VPC Flow Logs and CloudWatch integration
- **Cost Optimized**: Single NAT Gateway with proper routing

## 📋 Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** (v1.0+) installed
3. **Git** for version control
4. **AWS Account** with VPC creation permissions

## 🚀 Quick Start

### Step 1: Clone and Setup
```bash
git clone <your-repo>
cd VPC-Month
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Configure Variables
Edit `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
project_name = "cafe-aroma"
environment = "production"
your_ip_address = "45.120.59.253/32"  # Get from whatismyip.com
key_pair_name = "cafe-aroma-key" # create a key pair and replace name here
```

### Step 3: Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### Step 4: Verify Deployment
```bash
# Test web server connectivity
curl http://$(terraform output -raw web_server_public_ip)

# SSH to web server (then jump to private instances)
ssh -i your-key.pem ec2-user@$(terraform output -raw web_server_public_ip)
```

## 🏛️ Architecture Components

### Network Design
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-b)
- **Private Subnets**: 10.0.3.0/24 (AZ-a), 10.0.4.0/24 (AZ-b)

### Security Layers
1. **Internet Gateway**: Public internet access
2. **NAT Gateway**: Outbound internet for private subnets
3. **Security Groups**: Application-level firewall rules
4. **NACLs**: Subnet-level network controls
5. **VPC Flow Logs**: Network traffic monitoring

### Compute Resources
- **Web Servers**: 2x EC2 in public subnets (Load Balanced)
- **App Servers**: 2x EC2 in private subnets
- **Bastion Host**: Secure access to private resources

## 📊 Monitoring & Validation

### Built-in Monitoring
- VPC Flow Logs → CloudWatch
- EC2 Instance monitoring
- Load Balancer health checks

### Validation Tests
```bash
# Run validation script
./scripts/validate-infrastructure.sh

# Manual tests
terraform output  # View all outputs
aws ec2 describe-instances --filters "Name=tag:Project,Values=cafe-aroma"
```

## 🔧 Advanced Features (Stretch Goals)

### Load Balancer
- Application Load Balancer for web tier
- Health checks and auto-scaling ready
- SSL/TLS termination support

### VPC Endpoints
- S3 VPC Endpoint for private S3 access
- Reduces NAT Gateway costs
- Enhanced security

### VPC Peering 
```bash
# Deploy staging environment
cd environments/staging
terraform init
terraform apply

# Create peering connection
cd ../../peering
terraform init
terraform apply
```

## 📁 Project Structure

```
VPC-Month/
├── README.md                    # This file
├── main.tf                      # Root module
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example configuration
├── modules/
│   ├── vpc/                     # VPC and networking
│   ├── security/                # Security groups & NACLs
│   ├── compute/                 # EC2 instances
│   └── monitoring/              # CloudWatch & Flow Logs
├── environments/
│   ├── production/              # Production config
│   └── staging/                 # Staging environment
├── scripts/
│   ├── validate-infrastructure.sh
│   └── cleanup.sh
└── docs/
    ├── architecture-diagram.png
    └── security-analysis.md
```

## 🛡️ Security Best Practices Implemented

1. **Principle of Least Privilege**: Minimal required permissions
2. **Defense in Depth**: Multiple security layers
3. **Network Segmentation**: Public/private subnet isolation
4. **Access Control**: Bastion host for private access
5. **Monitoring**: Comprehensive logging and alerting

## 💰 Cost Optimization

- Single NAT Gateway (can be upgraded to multi-AZ)
- Right-sized EC2 instances (t3.micro for demo)
- VPC Endpoints to reduce data transfer costs
- Efficient CIDR allocation

## 🔄 Maintenance & Updates

### Regular Tasks
```bash
# Update infrastructure
terraform plan
terraform apply

# Backup state
aws s3 cp terraform.tfstate s3://your-backup-bucket/

# Security updates
./scripts/update-security-groups.sh
```

### Disaster Recovery
- Infrastructure is code-defined (easily reproducible)
- Multi-AZ deployment for high availability
- Automated backups via Terraform state

## 🚨 Troubleshooting

### Common Issues

1. **SSH Access Denied**
   - Verify your IP in terraform.tfvars
   - Check security group rules

2. **Private Instances Can't Reach Internet**
   - Verify NAT Gateway routing
   - Check route table associations

3. **Load Balancer Health Checks Failing**
   - Ensure web servers are running
   - Verify security group rules

### Debug Commands
```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Verify routing
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"

# Check security groups
aws ec2 describe-security-groups --group-ids $(terraform output -raw web_security_group_id)
```

## 📈 Performance Metrics

After implementation, you should see:
- **99.9%** uptime with multi-AZ deployment
- **<100ms** response time for web applications
- **Zero** public database exposure
- **Comprehensive** network traffic visibility

## 🎓 Learning Outcomes

By completing this project, you'll master:
- AWS VPC design principles
- Infrastructure as Code with Terraform
- Multi-tier application architecture
- AWS security best practices
- Network troubleshooting and monitoring

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Examine Terraform logs: `terraform apply -debug`

## 🧹 Cleanup

When done testing:
```bash
terraform destroy
# Confirm with 'yes' when prompted
```

---
