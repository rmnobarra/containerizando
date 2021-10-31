locals {
  name   = "postgreszupot"
  region = "us-east-1"
  tags = {
    Owner       = "Zup Academy"
    Environment = "dev"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.0"

  identifier = local.name

  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" 
  major_engine_version = "11"        
  instance_class       = "db.t3.micro"


	publicly_accessible = true

  name     = "postgreszupot"
  username = "sysadmin"
  password = "0uNs6QR883jv32Bq!"
  port     = 5432

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  multi_az = false

  subnet_ids = var.subnets_id

  vpc_security_group_ids = [module.security_group.security_group_id]

}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = local.name
  description = "Acesso postggresql"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Porta 5432"
      #cidr_blocks = "0.0.0.0/0"
      cidr_blocks = "${chomp(data.http.myip.body)}/32"
    },
  ]

  tags = local.tags

  depends_on = [data.http.myip]
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.rds.db_instance_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.rds.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.rds.db_instance_password
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.rds.db_instance_port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.rds.db_subnet_group_id
}