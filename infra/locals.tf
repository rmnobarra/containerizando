locals {
  name   = "postgreszup"
  region = var.aws_region
  tags = {
    Owner       = "Zup Academy"
    Environment = "dev"
  }
}
