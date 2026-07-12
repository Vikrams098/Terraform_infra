resource "aws_db_subnet_group" "kvs_db" {
  # AWS requires this name to be lowercase — lower() protects against a
  # future instance_name/identifier with uppercase characters breaking apply.
  name       = lower("${var.identifier}-subnet-group")
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.identifier}-subnet-group" })
}

# No egress block on purpose: a custom security group with zero rule blocks
# gets AWS's default allow-all-outbound stripped, which is correct here since
# a plain Postgres primary (no read replicas, no SNS event subscriptions)
# never needs to initiate outbound connections.
resource "aws_security_group" "kvs_sg" {
  name        = "${var.identifier}-sg"
  description = "Allow Postgres from the app instance only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  tags = merge(var.tags, { Name = "${var.identifier}-sg" })
}

# Generated (not user-supplied) so Terraform is the single source of truth for
# the master password; retrieve it after apply with:
#   terraform output -raw rds_master_password
# Special-character set is restricted to values that are safe inside a shell
# `docker run -e DB_PASSWORD=...` invocation (the deploy pipeline's usage).
resource "random_password" "master" {
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!#%^*_-+="
}

resource "aws_db_instance" "kvs_db" {
  identifier     = var.identifier
  engine         = "postgres"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.kvs_db.name
  vpc_security_group_ids = [aws_security_group.kvs_sg.id]
  publicly_accessible    = false

  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final"
  apply_immediately         = var.apply_immediately

  tags = merge(var.tags, { Name = var.identifier })
}
