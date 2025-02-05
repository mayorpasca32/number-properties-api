# provider.tf
provider "aws" {
  region = var.aws_region
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-2"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "number-properties-api"
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app" {
  name        = "${var.app_name}-sg"
  description = "Security group for API server"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
    description = "API port"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              # Update and install dependencies
              yum update -y
              yum install -y python3 python3-pip git
              
              # Install Python packages
              pip3 install flask flask-cors requests
              
              # Create app directory and application
              mkdir -p /app
              cat <<'EOT' > /app/app.py
              from flask import Flask, request, jsonify
              from flask_cors import CORS
              import math
              import requests
              
              app = Flask(__name__)
              CORS(app)
              
              def is_prime(n):
                  if n < 2:
                      return False
                  for i in range(2, int(math.sqrt(n)) + 1):
                      if n % i == 0:
                          return False
                  return True
              
              def is_perfect(n):
                  if n < 1:
                      return False
                  sum = 0
                  for i in range(1, n):
                      if n % i == 0:
                          sum += i
                  return sum == n
              
              def is_armstrong(n):
                  num_str = str(n)
                  power = len(num_str)
                  return n == sum(int(digit) ** power for digit in num_str)
              
              def get_properties(n):
                  properties = []
                  if is_armstrong(n):
                      properties.append("armstrong")
                  if n % 2 == 0:
                      properties.append("even")
                  else:
                      properties.append("odd")
                  return properties
              
              def get_digit_sum(n):
                  return sum(int(digit) for digit in str(n))
              
              def get_fun_fact(n):
                  try:
                      response = requests.get(f"http://numbersapi.com/{n}/math")
                      return response.text
                  except:
                      if is_armstrong(n):
                          digits = str(n)
                          power = len(digits)
                          return f"{n} is an Armstrong number because " + " + ".join(f"{d}^{power}" for d in digits) + f" = {n}"
                      return f"The number {n} has {len(str(n))} digits"
              
              @app.route('/api/classify-number', methods=['GET'])
              def classify_number():
                  try:
                      number = request.args.get('number')
                      if not number:
                          return jsonify({"number": None, "error": True}), 400
                      
                      number = int(number)
                      
                      response = {
                          "number": number,
                          "is_prime": is_prime(number),
                          "is_perfect": is_perfect(number),
                          "properties": get_properties(number),
                          "digit_sum": get_digit_sum(number),
                          "fun_fact": get_fun_fact(number)
                      }
                      
                      return jsonify(response), 200
                  
                  except ValueError:
                      return jsonify({"number": request.args.get('number'), "error": True}), 400
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=8080)
              EOT
              
              # Create service file
              cat <<'EOT' > /etc/systemd/system/api.service
              [Unit]
              Description=Number Properties API
              After=network.target
              
              [Service]
              User=root
              WorkingDirectory=/app
              ExecStart=/usr/bin/python3 /app/app.py
              Restart=always
              StandardOutput=append:/var/log/api.log
              StandardError=append:/var/log/api.error.log
              
              [Install]
              WantedBy=multi-user.target
              EOT
              
              # Set permissions and start service
              chmod 644 /etc/systemd/system/api.service
              systemctl daemon-reload
              systemctl enable api
              systemctl start api
              
              # Create a status check file
              echo "API setup complete" > /tmp/setup_complete
              EOF

  tags = {
    Name = var.app_name
  }
}

# Outputs
output "api_url" {
  description = "URL of the API"
  value       = "http://${aws_instance.app.public_ip}:8080"
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}
