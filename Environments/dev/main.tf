terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket         = "terraform-infra-resources"
    key            = "Environments/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "infra_table"
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
  # Public subnet: the app port is reached directly by the browser/frontend,
  # and SSM (used for deploys) needs outbound internet reachability.
  subnet_id     = module.vpc.public_subnet_ids[0]
  vpc_id        = module.vpc.vpc_id
  key_name      = var.key_name
  ingress_rules = var.ingress_rules
  tags          = local.common_tags
}

module "rds" {
  source = "../../Modules/rds"

  identifier                = "${var.instance_name}-postgres"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  allowed_security_group_id = module.ec2.security_group_id

  db_name             = var.db_name
  db_username         = var.db_username
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  engine_version      = var.db_engine_version
  multi_az            = var.db_multi_az
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot

  tags = local.common_tags
}
