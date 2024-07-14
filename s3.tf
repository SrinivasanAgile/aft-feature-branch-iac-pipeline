########################
# S3 bucket to store CFN templates
########################

resource "aws_s3_bucket" "cfn_templates" {
  bucket = var.cfn_templates_bucket
}

resource "aws_s3_bucket_versioning" "cfn_templates" {
  bucket = aws_s3_bucket.cfn_templates.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "cfn_templates" {
  bucket = aws_s3_bucket.cfn_templates.id
  policy = data.template_file.cfn_templates_bucket-policy.rendered
}

resource "aws_s3_object" "codepipeline_template" {
  bucket = aws_s3_bucket.cfn_templates.id
  key    = "aft-feature-branch-codepipeline.yaml"
  source = "./cfn_templates/aft-feature-branch-codepipeline.yaml"
  etag = "${filemd5("./cfn_templates/aft-feature-branch-codepipeline.yaml")}"
}

resource "aws_s3_object" "buildspec_file_account_tf_plan" {
  bucket = aws_s3_bucket.cfn_templates.id
  key    = "buildspec/tf-plan-account-customizations.yaml"
  source = "./cfn_templates/tf-plan-account-customizations.yaml"
  etag = "${filemd5("./cfn_templates/tf-plan-account-customizations.yaml")}"
}

resource "aws_s3_object" "buildspec_file_global_tf_plan" {
  bucket = aws_s3_bucket.cfn_templates.id
  key    = "buildspec/tf-plan-global-customizations.yaml"
  source = "./cfn_templates/tf-plan-global-customizations.yaml"
  etag = "${filemd5("./cfn_templates/tf-plan-global-customizations.yaml")}"
}

########################
# S3 bucket to store CodePipeline Artifacts
########################

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = var.codepipeline_artifacts_bucket
}

resource "aws_s3_bucket_versioning" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  policy = data.template_file.codepipeline_artifacts_bucket-policy.rendered
}