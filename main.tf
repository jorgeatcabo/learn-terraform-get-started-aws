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
