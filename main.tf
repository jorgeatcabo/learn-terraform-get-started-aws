############################################
# Provider
############################################
provider "aws" {
  region = "us-west-2"
}

############################################
# NAT Elastic IP
############################################
resource "aws_eip" "nat" {
  count  = 1
  domain = "vpc"
}

############################################
# VPC (terraform-aws-modules)
############################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway  = true
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat[*].id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

############################################
# Security Group - ALB
############################################
resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Security Group - EC2 (only ALB access)
############################################
resource "aws_security_group" "ec2" {
  name   = "ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# EC2 Instances (Private Subnets)
############################################
resource "aws_instance" "app" {
  count         = 2
  ami           = "ami-0a123456789abcdef" # Amazon Linux 2
  instance_type = "t3.micro"

  subnet_id              = module.vpc.private_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              echo "Hello from private EC2 ${count.index}" > /var/www/html/index.html
              EOF

  tags = {
    Name = "app-${count.index}"
  }
}

############################################
# Application Load Balancer (Public Subnets)
############################################
resource "aws_lb" "this" {
  name               = "my-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

############################################
# Target Group
############################################
resource "aws_lb_target_group" "this" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

############################################
# Target Group Attachments
############################################
resource "aws_lb_target_group_attachment" "this" {
  count            = 2
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}

############################################
# Listener
############################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
