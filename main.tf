provider "aws" {
  region = var.aws_region
  # profile = "terraform"
  # assume_role {
  #   role_arn     = "arn:aws:iam::197009133793:role/TerraformExecutionRole"
  #   session_name = "TerraformLocalDev"
  # }
}

# Data sources query cloud provider for info about other rss
# This data source fetches data about the latest AWS AMI that matches the filter
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id # ID to the data source above
  instance_type = var.instance_type

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name = var.instance_name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-5a", "ap-southeast-5b", "ap-southeast-5c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames = true
}
