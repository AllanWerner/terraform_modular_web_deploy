terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.63.0"
    }

  }
  required_version = "1.16.2"

  backend "s3" {
    region                   = "us-east-1"
    shared_credentials_files = ["../../.secrets/creds"]
    profile                  = "allan-web"
    bucket                   = "terraform-web-modular"
    key                      = "web-deploy.tfstate"
    use_lockfile             = true
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["../../.secrets/creds"]
  profile                  = "allan-web"
}

module "ec2" {
  source = "../modules/ec2_module"
  instancetype = "t3.micro"

  aws_common_tags = {
    Name = "ec2-web-allan"
  }

  ebs_volume_size = 1
}