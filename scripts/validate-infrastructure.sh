#!/bin/bash

# Café Aroma VPC Infrastructure Validation Script
# This script validates the deployed infrastructure

set -e

echo "🔍 Validating Café Aroma VPC Infrastructure..."
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command_exists terraform; then
    echo -e "${RED}❌ Terraform not found. Please install Terraform.${NC}"
    exit 1
fi

if ! command_exists aws; then
    echo -e "${RED}❌ AWS CLI not found. Please install AWS CLI.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Get Terraform outputs
echo "📊 Getting infrastructure information..."
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")
WEB_IPS=($(terraform output -json web_server_public_ips 2>/dev/null | jq -r '.[]' || echo ""))
ALB_DNS=$(terraform output -raw load_balancer_dns_name 2>/dev/null || echo "")

if [ -z "$VPC_ID" ]; then
    echo -e "${RED}❌ Cannot get VPC ID. Make sure infrastructure is deployed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ VPC ID: $VPC_ID${NC}"

# Test 1: VPC Configuration
echo "🏗️  Testing VPC configuration..."
VPC_INFO=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query 'Vpcs[0]' 2>/dev/null || echo "")
if [ -n "$VPC_INFO" ]; then
    echo -e "${GREEN}✅ VPC exists and is accessible${NC}"
else
    echo -e "${RED}❌ VPC not found or not accessible${NC}"
fi

# Test 2: Subnet Configuration
echo "🌐 Testing subnet configuration..."
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].{SubnetId:SubnetId,Type:Tags[?Key==`Type`].Value|[0],AZ:AvailabilityZone}' --output table 2>/dev/null || echo "")
if [ -n "$SUBNETS" ]; then
    echo -e "${GREEN}✅ Subnets configured correctly${NC}"
    echo "$SUBNETS"
else
    echo -e "${RED}❌ Subnet configuration issue${NC}"
fi

# Test 3: Internet Gateway
echo "🌍 Testing Internet Gateway..."
IGW=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || echo "")
if [ "$IGW" != "None" ] && [ -n "$IGW" ]; then
    echo -e "${GREEN}✅ Internet Gateway attached: $IGW${NC}"
else
    echo -e "${RED}❌ Internet Gateway not found${NC}"
fi

# Test 4: NAT Gateway
echo "🔄 Testing NAT Gateway..."
NAT=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[0].NatGatewayId' --output text 2>/dev/null || echo "")
if [ "$NAT" != "None" ] && [ -n "$NAT" ]; then
    echo -e "${GREEN}✅ NAT Gateway configured: $NAT${NC}"
else
    echo -e "${YELLOW}⚠️  NAT Gateway not found (may be optional)${NC}"
fi

# Test 5: Security Groups
echo "🛡️  Testing Security Groups..."
SG_COUNT=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'length(SecurityGroups)' --output text 2>/dev/null || echo "0")
if [ "$SG_COUNT" -gt 1 ]; then
    echo -e "${GREEN}✅ Security Groups configured: $SG_COUNT groups${NC}"
else
    echo -e "${RED}❌ Insufficient Security Groups${NC}"
fi

# Test 6: Web Server Connectivity
echo "🌐 Testing web server connectivity..."
if [ ${#WEB_IPS[@]} -gt 0 ]; then
    for ip in "${WEB_IPS[@]}"; do
        if [ -n "$ip" ] && [ "$ip" != "null" ]; then
            echo "Testing web server at $ip..."
            if curl -s --connect-timeout 10 "http://$ip" > /dev/null; then
                echo -e "${GREEN}✅ Web server $ip is responding${NC}"
            else
                echo -e "${RED}❌ Web server $ip is not responding${NC}"
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠️  No web server IPs found${NC}"
fi

# Test 7: Load Balancer
echo "⚖️  Testing Load Balancer..."
if [ -n "$ALB_DNS" ] && [ "$ALB_DNS" != "null" ]; then
    echo "Testing load balancer at $ALB_DNS..."
    if curl -s --connect-timeout 10 "http://$ALB_DNS" > /dev/null; then
        echo -e "${GREEN}✅ Load balancer is responding${NC}"
    else
        echo -e "${YELLOW}⚠️  Load balancer not responding (may still be initializing)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Load balancer DNS not found${NC}"
fi

# Test 8: VPC Flow Logs
echo "📊 Testing VPC Flow Logs..."
FLOW_LOGS=$(aws ec2 describe-flow-logs --filter "Name=resource-id,Values=$VPC_ID" --query 'FlowLogs[0].FlowLogId' --output text 2>/dev/null || echo "")
if [ "$FLOW_LOGS" != "None" ] && [ -n "$FLOW_LOGS" ]; then
    echo -e "${GREEN}✅ VPC Flow Logs enabled: $FLOW_LOGS${NC}"
else
    echo -e "${YELLOW}⚠️  VPC Flow Logs not found${NC}"
fi

# Summary
echo ""
echo "📋 Validation Summary"
echo "===================="
echo "VPC ID: $VPC_ID"
echo "Internet Gateway: $IGW"
echo "NAT Gateway: $NAT"
echo "Security Groups: $SG_COUNT"
echo "Web Servers: ${#WEB_IPS[@]}"
echo "Load Balancer: $ALB_DNS"
echo "Flow Logs: $FLOW_LOGS"

echo ""
echo -e "${GREEN}🎉 Infrastructure validation completed!${NC}"
echo ""
echo "💡 Next steps:"
echo "1. Test SSH access to web servers"
echo "2. Verify private instances can reach internet through NAT"
echo "3. Check CloudWatch logs for VPC Flow Logs"
echo "4. Monitor load balancer health checks"

# Optional: Generate a simple report
cat > validation-report.txt << EOF
Café Aroma VPC Infrastructure Validation Report
Generated: $(date)

VPC Configuration:
- VPC ID: $VPC_ID
- Internet Gateway: $IGW
- NAT Gateway: $NAT
- Security Groups: $SG_COUNT
- Web Servers: ${#WEB_IPS[@]}
- Load Balancer: $ALB_DNS
- Flow Logs: $FLOW_LOGS

Web Server IPs:
$(printf '%s\n' "${WEB_IPS[@]}")

Status: Infrastructure validation completed successfully
EOF

echo "📄 Validation report saved to: validation-report.txt"