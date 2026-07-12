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
    key            = "Environments/main/terraform.tfstate"
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

module "dns" {
  source = "../../Modules/dns"

  zone_name = var.domain_name
  tags      = local.common_tags
}

module "acm" {
  source = "../../Modules/acm"

  domain_name     = var.domain_name
  route53_zone_id = module.dns.zone_id
  tags            = local.common_tags
}

module "alb" {
  source = "../../Modules/alb"

  name              = var.instance_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
  route53_zone_id   = module.dns.zone_id
  domain_name       = var.domain_name
  tags              = local.common_tags
}

module "asg" {
  source = "../../Modules/asg"

  name                  = var.instance_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  min_size              = var.asg_min_size
  max_size              = var.asg_max_size
  desired_capacity      = var.asg_desired_capacity
  tags                  = local.common_tags
}

module "rds" {
  source = "../../Modules/rds"

  identifier                = "${var.instance_name}-postgres"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  allowed_security_group_id = module.asg.security_group_id

  db_name                 = var.db_name
  db_username             = var.db_username
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine_version          = var.db_engine_version
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = local.common_tags
}
