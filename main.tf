provider "aws" {
  region  = "ap-southeast-5"
  profile = "terraform"
  assume_role {
    role_arn     = "arn:aws:iam::197009133793:role/TerraformExecutionRole"
    session_name = "TerraformLocalDev"
  }
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

  tags = {
    Name = var.instance_name
  }
}
