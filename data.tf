# Get current account id
data "aws_caller_identity" "current" {}

# Get KMS key ARN for aft
data "aws_kms_key" "alias_aft" {
  key_id = "alias/aft"
}

# Get KMS key ARN for aft-backend
data "aws_kms_key" "alias_aft_backend" {
  key_id = "alias/aft-backend-${data.aws_caller_identity.current.account_id}-kms-key"
}

# eventbridge pattern to trigger lambda
data "template_file" "eventbridge_pattern" {
  template = file("./policy_files/event_pattern.json")
}

########################
# Template file to render S3 bucket policy
########################
data "template_file" "cfn_templates_bucket-policy" {
  template = file("./policy_files/bucket_policy.json")
  vars = {
    bucket_arn = aws_s3_bucket.cfn_templates.arn
  }
}

data "template_file" "codepipeline_artifacts_bucket-policy" {
  template = file("./policy_files/bucket_policy.json")
  vars = {
    bucket_arn = aws_s3_bucket.codepipeline_artifacts.arn
  }
}

########################
# Template file to render lambda policy
########################
data "template_file" "lambda_policy" {
  template = file("./policy_files/lambda_policy.json")

  vars = {
    account_id        = data.aws_caller_identity.current.account_id
    bucket_name       = aws_s3_bucket.cfn_templates.id
    codebuild_role    = aws_iam_role.aft_feature_branch_codebuild_role.arn
    codepipeline_role = aws_iam_role.aft_feature_branch_codepipeline_role.arn
  }
}

########################
# Template file to render codebuild policy
########################
data "template_file" "codebuild_policy" {
  template = file("./policy_files/codebuild_policy.json")

  vars = {
    account_id          = data.aws_caller_identity.current.account_id
    bucket_name         = aws_s3_bucket.cfn_templates.id
    kms_key_aft         = data.aws_kms_key.alias_aft.arn
    kms_key_aft_backend = data.aws_kms_key.alias_aft_backend.arn
  }
}

########################
# Template file to render codepipeline policy
########################
data "template_file" "codepipeline_policy" {
  template = file("./policy_files/codepipeline_policy.json")

  vars = {
    account_id          = data.aws_caller_identity.current.account_id
    artifacts_bucket    = aws_s3_bucket.codepipeline_artifacts.id
    kms_key_aft         = data.aws_kms_key.alias_aft.arn
    kms_key_aft_backend = data.aws_kms_key.alias_aft_backend.arn
  }
}

# zipped lambda source code
data "archive_file" "zipfile" {
  type        = "zip"
  source_file = "${path.module}/aft-repo-feature-branch-pipeline/aft-repo-feature-branch-pipeline.py"
  output_path = "${path.module}/aft-repo-feature-branch-pipeline.zip"
}