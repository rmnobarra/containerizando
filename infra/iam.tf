
resource "aws_iam_role" "containerizando" {
  name = "containerizando"

  managed_policy_arns = [aws_iam_policy.ecrPublicPolicy.arn, aws_iam_policy.cloudwatchPolicy.arn]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatchPolicy" {
  name = "cloudwatchPolicy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "autoscaling:Describe*",
            "cloudwatch:*",
            "logs:*",
            "sns:*",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:GetRole"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
          "Condition" : {
            "StringLike" : {
              "iam:AWSServiceName" : "events.amazonaws.com"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_policy" "ecrPublicPolicy" {
  name = "EcrPublicPolicy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ecr-public:GetAuthorizationToken",
            "sts:GetServiceBearerToken",
            "ecr-public:BatchCheckLayerAvailability",
            "ecr-public:GetRepositoryPolicy",
            "ecr-public:DescribeRepositories",
            "ecr-public:DescribeRegistries",
            "ecr-public:DescribeImages",
            "ecr-public:DescribeImageTags",
            "ecr-public:GetRepositoryCatalogData",
            "ecr-public:GetRegistryCatalogData",
            "ecr-public:InitiateLayerUpload",
            "ecr-public:UploadLayerPart",
            "ecr-public:CompleteLayerUpload",
            "ecr-public:PutImage"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "containerizando" {
  role = aws_iam_role.containerizando.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.containerizando.arn}",
        "${aws_s3_bucket.containerizando.arn}/*"
      ]
    },
        {
            "Sid": "EKSREADONLY",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:DescribeUpdate",
                "eks:DescribeCluster"
            ],
            "Resource": "*"
        },
        {
            "Sid": "STSASSUME",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "${data.aws_iam_role.CodeBuildKubectlRole.arn}"
        }
  ]
}
POLICY
}



data "aws_iam_role" "CodeBuildKubectlRole" {
  name = "CodeBuildKubectlRole"
}