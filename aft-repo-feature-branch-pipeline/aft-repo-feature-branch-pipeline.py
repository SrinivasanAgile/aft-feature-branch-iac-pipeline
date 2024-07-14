import boto3
import os
import logging
logger = logging.getLogger()
logger.setLevel("INFO")

BucketName = os.environ['cfn_templates_bucket_name']
ArtifactsBucket = os.environ['pipeline_artifacts_bucket_name']
CodePipelineARN = os.environ['codepipeline_role']
CodeBuildARN = os.environ['codebuild_role']
def lambda_handler(event, context):
    logger.info("Inside the handler function")
    logger.info(event)
    Region = event['region']
    Account = event['account']
    RepositoryName = event['detail']['repositoryName']
    NewBranch = event['detail']['referenceName']
    Event = event['detail']['event']
    if Event == "referenceCreated":
        cf_client = boto3.client('cloudformation')
        logger.info("Assumed CFN client and creating stack")
        cf_client.create_stack(
            StackName=f'Pipeline-{RepositoryName}-{NewBranch}',
            TemplateURL=f'https://s3.amazonaws.com/{BucketName}/aft-feature-branch-codepipeline.yaml',
            Parameters=[
                {
                    'ParameterKey': 'RepositoryName',
                    'ParameterValue': RepositoryName,
                    'UsePreviousValue': False
                },
                {
                    'ParameterKey': 'BranchName',
                    'ParameterValue': NewBranch,
                    'UsePreviousValue': False
                },
                {
                    'ParameterKey': 'BucketName',
                    'ParameterValue': BucketName,
                    'UsePreviousValue': False
                },
                {
                    'ParameterKey': 'CodePipelineARN',
                    'ParameterValue': CodePipelineARN,
                    'UsePreviousValue': False
                },
                {
                    'ParameterKey': 'CodeBuildARN',
                    'ParameterValue': CodeBuildARN,
                    'UsePreviousValue': False
                },
                {
                    'ParameterKey': 'ArtifactsBucket',
                    'ParameterValue': ArtifactsBucket,
                    'UsePreviousValue': False
                }
            ],
            OnFailure='ROLLBACK',
            Capabilities=['CAPABILITY_NAMED_IAM']
        )
    else:
        cf_client = boto3.client('cloudformation')
        logger.info("Assumed CFN client and deleting stack")
        cf_client.delete_stack(
            StackName=f'Pipeline-{RepositoryName}-{NewBranch}'
        )