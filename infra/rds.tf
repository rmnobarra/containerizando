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

  name     = var.postgresql_db_name
  username = var.postgresql_db_user
  password = var.postgresql_db_pass
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
  description = "Acesso postggres"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Porta 5432"
      cidr_blocks = "${chomp(data.http.myip.body)}/32,${var.vpc_cidr}"
    },
  ]

  tags = local.tags

  depends_on = [data.http.myip]
}