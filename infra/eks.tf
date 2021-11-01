data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"

  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  vpc_id          = var.vpc_id
  subnets         = var.subnets_id

  worker_groups = [
    {

      name                 = "worker-group-1"
      instance_type = "t3.small"
      asg_desired_capacity = 2
      asg_max_size = 5
      asg_min_size  = 2
      autoscaling_enabled = true
      public_ip            = true

    }
  ]
}