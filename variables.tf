## General variable

variable "memory_size" {
  description = "Size of the Lambda function running the scheduler, increase size when processing large numbers of instances."
  type        = string
  default     = "128"
}

variable "timeout" {
  description = "Timeout for the Lambda function."
  type        = string
  default     = "900"
}

variable "cfn_templates_bucket" {
  description = "Bucket to store AWS CloudFormation templates"
  type        = string
  default     = "aft-feature-branch-cfn-templates"
}

variable "codepipeline_artifacts_bucket" {
  description = "Bucket to store artifacts from AWS CodePipeline"
  type        = string
  default     = "aft-feature-branch-pipeline-artifacts"
}