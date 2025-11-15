# Compute Module - EC2 Instances

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for web servers
locals {
  web_user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Create enhanced web page with modern UI
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>☕ Café Aroma - Premium Coffee Experience</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #8B4513 0%, #D2691E 100%);
                min-height: 100vh;
                padding: 20px;
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
                background: rgba(255, 255, 255, 0.95);
                border-radius: 20px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                overflow: hidden;
            }
            .header {
                background: linear-gradient(45deg, #8B4513, #A0522D);
                color: white;
                padding: 40px;
                text-align: center;
                position: relative;
            }
            .header::before {
                content: '☕';
                font-size: 60px;
                position: absolute;
                top: 20px;
                left: 50%;
                transform: translateX(-50%);
                opacity: 0.3;
            }
            .header h1 {
                font-size: 2.5em;
                margin-bottom: 10px;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            .subtitle {
                font-size: 1.2em;
                opacity: 0.9;
                font-weight: 300;
            }
            .content {
                padding: 40px;
            }
            .grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 30px;
                margin-bottom: 40px;
            }
            .card {
                background: white;
                border-radius: 15px;
                padding: 25px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.1);
                border-left: 5px solid #8B4513;
                transition: transform 0.3s ease;
            }
            .card:hover {
                transform: translateY(-5px);
            }
            .card h3 {
                color: #8B4513;
                margin-bottom: 15px;
                font-size: 1.3em;
            }
            .server-info {
                background: linear-gradient(135deg, #e8f4f8, #f0f8ff);
            }
            .architecture-status {
                background: linear-gradient(135deg, #f0fff0, #e6ffe6);
            }
            .menu-preview {
                background: linear-gradient(135deg, #fff8dc, #ffeaa7);
            }
            .status-list {
                list-style: none;
            }
            .status-list li {
                padding: 8px 0;
                border-bottom: 1px solid rgba(139, 69, 19, 0.1);
            }
            .status-list li:last-child {
                border-bottom: none;
            }
            .badge {
                display: inline-block;
                background: #28a745;
                color: white;
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 0.8em;
                margin-left: 10px;
            }
            .footer {
                background: #f8f9fa;
                padding: 30px;
                text-align: center;
                border-top: 1px solid #dee2e6;
            }
            .btn {
                display: inline-block;
                background: linear-gradient(45deg, #8B4513, #A0522D);
                color: white;
                padding: 12px 30px;
                border-radius: 25px;
                text-decoration: none;
                margin: 10px;
                transition: all 0.3s ease;
                box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
            }
            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(139, 69, 19, 0.4);
            }
            @keyframes pulse {
                0% { opacity: 1; }
                50% { opacity: 0.7; }
                100% { opacity: 1; }
            }
            .live-indicator {
                display: inline-block;
                width: 10px;
                height: 10px;
                background: #28a745;
                border-radius: 50%;
                margin-right: 8px;
                animation: pulse 2s infinite;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>☕ Café Aroma</h1>
                <p class="subtitle">Premium Coffee Experience - Cloud Infrastructure Dashboard</p>
            </div>
            
            <div class="content">
                <div class="grid">
                    <div class="card server-info">
                        <h3><span class="live-indicator"></span>Server Information</h3>
                        <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
                        <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
                        <p><strong>Private IP:</strong> $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
                        <p><strong>Public IP:</strong> $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>
                        <p><strong>Region:</strong> us-east-1</p>
                        <span class="badge">LIVE</span>
                    </div>
                    
                    <div class="card architecture-status">
                        <h3>🏗️ VPC Architecture Status</h3>
                        <ul class="status-list">
                            <li>✅ Multi-AZ deployment for high availability</li>
                            <li>✅ Application Load Balancer distributing traffic</li>
                            <li>✅ Private subnets for secure backend services</li>
                            <li>✅ NAT Gateway for controlled internet access</li>
                            <li>✅ Security groups with layered protection</li>
                            <li>✅ VPC Flow Logs for monitoring</li>
                        </ul>
                    </div>
                    
                    <div class="card menu-preview">
                        <h3>☕ Today's Specials</h3>
                        <ul class="status-list">
                            <li>🌟 Signature Espresso Blend</li>
                            <li>🥐 Fresh Croissants & Pastries</li>
                            <li>🍃 Organic Cold Brew</li>
                            <li>🎂 Artisan Desserts</li>
                            <li>🥪 Gourmet Sandwiches</li>
                        </ul>
                        <p style="margin-top: 15px; font-style: italic; color: #8B4513;">"Serving excellence, one cup at a time"</p>
                    </div>
                </div>
                
                <div style="text-align: center; margin-top: 30px;">
                    <h2 style="color: #8B4513; margin-bottom: 20px;">🎯 Infrastructure Highlights</h2>
                    <div style="display: flex; justify-content: space-around; flex-wrap: wrap; gap: 20px;">
                        <div style="text-align: center;">
                            <div style="font-size: 2em; color: #28a745;">99.9%</div>
                            <div>Uptime SLA</div>
                        </div>
                        <div style="text-align: center;">
                            <div style="font-size: 2em; color: #17a2b8;">2 AZ</div>
                            <div>Multi-Zone Deploy</div>
                        </div>
                        <div style="text-align: center;">
                            <div style="font-size: 2em; color: #ffc107;">4 Tiers</div>
                            <div>Security Layers</div>
                        </div>
                        <div style="text-align: center;">
                            <div style="font-size: 2em; color: #dc3545;">0</div>
                            <div>Public DB Exposure</div>
                        </div>
                    </div>
>
                </div>
            </div>
            
            <div class="footer">
                <p style="margin-bottom: 15px;">🚀 <strong>Powered by AWS Production-Ready VPC Architecture</strong></p>
                <a href="#" class="btn">☕ Order Now</a>
                <a href="#" class="btn">📱 Mobile App</a>
                <a href="#" class="btn">🎁 Loyalty Program</a>
                <p style="margin-top: 20px; color: #6c757d; font-size: 0.9em;">
                    Infrastructure as Code | Terraform Managed | Multi-AZ Deployment<br>
                    <em>This server is running in a secure, scalable, production-ready environment!</em>
                </p>
            </div>
        </div>
    </body>
    </html>
HTML

    # Install CloudWatch agent
    yum install -y amazon-cloudwatch-agent
    
    # Create health check endpoint
    echo "OK" > /var/www/html/health
    
    # Restart httpd to ensure everything is working
    systemctl restart httpd
  EOF
  )

  app_user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nodejs npm
    
    # Create a simple app server
    mkdir -p /opt/app
    cat > /opt/app/server.js << 'JS'
const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
  const response = {
    message: 'Café Aroma App Server',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: 'production'
  };
  
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(response, null, 2));
});

server.listen(8080, () => {
  console.log('App server running on port 8080');
});
JS

    # Start the app server
    cd /opt/app
    node server.js &
    
    # Install CloudWatch agent
    yum install -y amazon-cloudwatch-agent
  EOF
  )
}

# Web Server Instances (Public Subnets)
resource "aws_instance" "web" {
  count = length(var.public_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.web_security_group_id]
  subnet_id              = var.public_subnet_ids[count.index]
  
  user_data = local.web_user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-web-${count.index + 1}"
    Type = "WebServer"
    Tier = "Public"
  }
}

# App Server Instances (Private Subnets)
resource "aws_instance" "app" {
  count = length(var.private_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.app_security_group_id]
  subnet_id              = var.private_subnet_ids[count.index]
  
  user_data = local.app_user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
    Type = "AppServer"
    Tier = "Private"
  }
}