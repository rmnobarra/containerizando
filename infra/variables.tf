variable "repo_url" {
  type    = string
  default = "https://github.com/rmnobarra/containerizando.git"
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