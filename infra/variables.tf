variable "aws_region" {
  default = "us-east-1"

}
variable "repo_url" {
  type    = string
  default = "https://github.com/rmnobarra/containerizando"
}

variable "codebuild_arn" {
  type    = string
  default = "arn:aws:iam::208471844409:role/CodebuildContainerizando"

}


variable "vpc_id" {
  default = "vpc-0cb22071"
}

variable "subnets_id" {
  type    = list(any)
  default = ["subnet-acb58da2", "subnet-a0b9ffc6", "subnet-43d5961c"]

}

variable "sg_id" {
  type    = list(any)
  default = ["sg-04b3a84098b03347e"]

}

variable "postgresql_db_name" {

}

variable "postgresql_db_user" {

}


variable "postgresql_db_pass" {

}

variable "dockerhub_username" {

}

variable "dockerhub_token" {

}

variable "vpc_cidr" {

}

variable "cluster_name" {
  type    = string
  default = "containerizando"
}

variable "cluster_version" {
  type    = string
  default = "1.21"

}

