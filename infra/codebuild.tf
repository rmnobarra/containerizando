

resource "aws_codebuild_project" "containerizando" {
  name          = "containerizando-project"
  description   = "containerizando project"
  build_timeout = "5"
  service_role  = aws_iam_role.containerizando.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.containerizando.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode             = false


    environment_variable {
      name  = "SOME_KEY1"
      value = "SOME_VALUE1"
    }

    environment_variable {
      name  = "SOME_KEY2"
      value = "SOME_VALUE2"
      type  = "PARAMETER_STORE"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.containerizando.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.repo_url

    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnets_id

    security_group_ids = var.sg_id
  }

  tags = {
    Environment = "Test"
  }
}