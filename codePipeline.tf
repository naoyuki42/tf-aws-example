# resource "aws_codepipeline" "default" {
#   name     = "default"
#   role_arn = module.codepipeline_role.iam_role_arn

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "ThirdParty"
#       provider         = "GitHub"
#       version          = 1
#       output_artifacts = ["Source"]

#       configuration = {
#         Owner                = "your-github-name"
#         Repo                 = "your-repository"
#         Branch               = "master"
#         PollForSourceChanges = false
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       version          = 1
#       input_artifacts  = ["Source"]
#       output_artifacts = ["Build"]

#       configuration = {
#         ProjectName = aws_codebuild_project.default.id
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "ECS"
#       version         = 1
#       input_artifacts = ["Build"]

#       configuration = {
#         ClusterName = aws_ecs_cluster.default.name
#         ServiceName = aws_ecs_service.default.name
#         FileName    = "imagedefinitions.json"
#       }
#     }
#   }

#   artifact_store {
#     location = aws_s3_bucket.artifact.id
#     type     = "S3"
#   }
# }

# resource "aws_codepipeline_webhook" "default" {
#   name            = "default"
#   target_pipeline = aws_codepipeline.default.name
#   target_action   = "Scource"
#   authentication  = "GITHUB_HMAC"

#   authentication_configuration {
#     secret_token = "VeryRandomStringMoreThan20Byte!"
#   }

#   filter {
#     json_path    = "$.ref"
#     match_equals = "refs/heads/{Branch}"
#   }
# }

# provider "github" {
#   organization = "your-github-name"
# }

# resource "github_repository_webhook" "default" {
#   repository = "your-repository"

#   configuration {
#     url          = aws_codepipeline_webhook.default.url
#     secret       = "VeryRandomStringMoreThan20Byte!"
#     content_type = "json"
#     insecure_ssl = false
#   }

#   events = ["push"]
# }

resource "aws_s3_bucket" "artifact" {
  bucket = "artifact--20220818"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 180
    }
  }
}

module "codepipeline_role" {
  source     = "./iam_role"
  name       = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
}
