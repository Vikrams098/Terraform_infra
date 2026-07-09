terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-infra-resources"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-resources"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../Modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  tags                 = local.common_tags
}

module "ec2" {
  source = "../../Modules/ec2"

  instance_name = var.instance_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  # Place the VM in the first private subnet; change to public_subnet_ids[0] for a bastion
  subnet_id     = module.vpc.private_subnet_ids[0]
  vpc_id        = module.vpc.vpc_id
  key_name      = var.key_name
  ingress_rules = var.ingress_rules
  tags          = local.common_tags
}
