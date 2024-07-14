#EventBridge rule
resource "aws_cloudwatch_event_rule" "aft_feature_branch" {
  name          = "aft-repos-feature_branch"
  description   = "EventBridge Rule to trigger when feature branch is created in AFT account or global customizations repositories"
  event_pattern = data.template_file.eventbridge_pattern.rendered
}

#Eventbridge rule invokes Lambda
resource "aws_cloudwatch_event_target" "feaure_branch" {
  rule      = aws_cloudwatch_event_rule.aft_feature_branch.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.aft_repo_feature_branch.arn
}

# Lambda function with all dependencies and environmental variables
resource "aws_lambda_function" "aft_repo_feature_branch" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  description      = "This function is to create terraform CI-CD pipeline for feature branches in AFT repositories"
  filename         = "${path.module}/aft-repo-feature-branch-pipeline.zip"
  function_name    = "aft-repo-feature-branch-pipeline"
  role             = aws_iam_role.aft_feature_branch_lambda_role.arn
  handler          = "aft-repo-feature-branch-pipeline.lambda_handler"
  runtime          = "python3.12"
  timeout          = var.timeout
  memory_size      = var.memory_size
  source_code_hash = data.archive_file.zipfile.output_base64sha256
  environment {
    variables = {
      cfn_templates_bucket_name      = aws_s3_bucket.cfn_templates.id
      pipeline_artifacts_bucket_name = aws_s3_bucket.codepipeline_artifacts.id
      codebuild_role                 = aws_iam_role.aft_feature_branch_codebuild_role.arn
      codepipeline_role              = aws_iam_role.aft_feature_branch_codepipeline_role.arn
    }
  }
  tags = merge(
    {
      "Name" = "aft-repo-feature-branch-pipeline",
    }
  )
}

# permissions to invoke lambda by cloudwatch events rule
resource "aws_lambda_permission" "aft_repo_feature_branch_invoke_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aft_repo_feature_branch.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aft_feature_branch.arn
}