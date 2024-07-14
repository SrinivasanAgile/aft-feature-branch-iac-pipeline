######################################
#### IAM for Lambda ####
######################################
data "aws_iam_policy_document" "aft_feature_branch_lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "aft_feature_branch_lambda_policy" {
  name        = "aft-feature-branch-lambda-policy"
  path        = "/"
  description = "IAM permissions for lambda to create pipelines for every feature branches on AFT repositories"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.template_file.lambda_policy.rendered
  tags = {
    "Name" = "aft-feature-branch-lambda-policy"
  }
}

resource "aws_iam_role" "aft_feature_branch_lambda_role" {
  name               = "aft-feature-branch-lambda-role"
  description        = "IAM role for lambda to create pipelines for every feature branches on AFT repositories"
  assume_role_policy = data.aws_iam_policy_document.aft_feature_branch_lambda_role.json
  managed_policy_arns = [
    aws_iam_policy.aft_feature_branch_lambda_policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  tags = {
    "Name" = "aft-feature-branch-lambda-role"
  }
}

###################################
#### IAM for Codebuild project ####
###################################
data "aws_iam_policy_document" "aft_feature_branch_codebuild_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "aft_feature_branch_codebuild_policy" {
  name        = "aft-feature-branch-codebuild-policy"
  path        = "/"
  description = "IAM permissions for codebuild project to run terraform actions on feature branches from AFT repositories"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.template_file.codebuild_policy.rendered
  tags = {
    "Name" = "aft-feature-branch-codebuild-policy"
  }
}

resource "aws_iam_role" "aft_feature_branch_codebuild_role" {
  name               = "aft-feature-branch-codebuild-role"
  description        = "IAM role for codebuild project to run terraform actions on feature branches from AFT repositories"
  assume_role_policy = data.aws_iam_policy_document.aft_feature_branch_codebuild_role.json
  managed_policy_arns = [
    aws_iam_policy.aft_feature_branch_codebuild_policy.arn,
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
  tags = {
    "Name" = "aft-feature-branch-codebuild-role"
  }
}

######################################
#### IAM for CodePipeline Service ####
######################################
data "aws_iam_policy_document" "aft_feature_branch_codepipeline_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "aft_feature_branch_codepipeline_policy" {
  name        = "aft-feature-branch-codepipeline-policy"
  path        = "/"
  description = "IAM permissions for codepipeline service to create pipeline with stages for every feature branches on AFT repositories"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.template_file.codepipeline_policy.rendered
  tags = {
    "Name" = "aft-feature-branch-codepipeline-policy"
  }
}

resource "aws_iam_role" "aft_feature_branch_codepipeline_role" {
  name               = "aft-feature-branch-codepipeline-role"
  description        = "IAM role for codepipeline service to create pipeline with stages for every feature branches on AFT repositories"
  assume_role_policy = data.aws_iam_policy_document.aft_feature_branch_codepipeline_role.json
  managed_policy_arns = [
    aws_iam_policy.aft_feature_branch_codepipeline_policy.arn,
  ]
  tags = {
    "Name" = "aft-feature-branch-codepipeline-role"
  }
}