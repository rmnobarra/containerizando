provider "aws" {
  region = "us-east-1"
}


terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.14.0"
    }
  }
}

provider "postgresql" {
  host            = module.rds.db_instance_address
  port            = 5432
  database        = var.postgresql_db_name
  username        = var.postgresql_db_user
  password        = var.postgresql_db_pass
  sslmode         = "disable"
  connect_timeout = 600
}