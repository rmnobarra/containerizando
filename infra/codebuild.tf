

resource "aws_codebuild_project" "containerizando" {
  name          = "containerizando"
  description   = "containerizando project"
  build_timeout = "5"
  service_role  = aws_iam_role.containerizando.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode = true

    environment_variable {
      name  = "DOCKERHUB_USERNAME"
      value = var.dockerhub_username
    }

    environment_variable {
      name  = "DOCKERHUB_TOKEN"
      value = var.dockerhub_token
    }

    environment_variable {
      name  = "DB_URL"
      value = "jdbc:postgresql://${module.rds.db_instance_address}/containerizando"
    }

    environment_variable {
      name  = "DB_USER"
      value = module.rds.db_instance_username
    }

    environment_variable {
      name  = "DB_PASS"
      value = module.rds.db_instance_password
    }

    environment_variable {
      name  = "IMAGE_URL"
      value = aws_ecrpublic_repository.containerizando.repository_uri
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = "us-east-1"
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }

    environment_variable {
      name  = "ARN_ROLE"
      value = data.aws_iam_role.CodeBuildKubectlRole.arn
    }
  }

  source {
    buildspec       = "pipeline/buildspec.yaml"
    type            = "GITHUB"
    location        = var.repo_url
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "main"

  #  vpc_config {
  #    vpc_id = var.vpc_id
  #
  #    subnets = var.subnets_id
  #
  #
  #    security_group_ids = var.sg_id
  #
  #  }

  tags = {
    ManagedBy = "Terraform"
  }

  depends_on = [
    aws_iam_role.containerizando, module.rds

  ]
}
