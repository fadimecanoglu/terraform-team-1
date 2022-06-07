# read data from created VPC
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    # you shoud have S3 backet with name: terraform-tfstate-<Account_ID> 
    bucket = "terraform-tfstate-${local.account_id}" 

    key    = "project-team-1/dev/vpc"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ps1    = data.terraform_remote_state.vpc.outputs.public_subnet1
  ps2    = data.terraform_remote_state.vpc.outputs.public_subnet2
  ps3    = data.terraform_remote_state.vpc.outputs.public_subnet3
  account_id = data.aws_caller_identity.current.account_id
}


resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "dbpass" {
  name  = var.db_name
  type  = "SecureString"
  value = random_password.password.result
}

resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  db_name                = var.db_name
  password               = random_password.password.result
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = var.tags
}

