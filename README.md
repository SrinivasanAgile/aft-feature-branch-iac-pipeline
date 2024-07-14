# aft-feature-branch-iac-pipeline

## Description
This repository hosts the terraform code for implementing event-driven architecture to create and destroy IaC pipelines for every feature branch in AFT customization repositories.

## Solution Architecture
![DevOps_IaC_Pipeline_for_AFT_Repositories](https://github.com/user-attachments/assets/3f895baa-6745-46e3-8dd5-e311136983b2)

## Workflow
1. Amazon EventBridge rule has been created to monitor any feature branch being created/deleted from ‘main’ branch of ‘aft-account-customizations’ and ‘aft-global-customizations’ repository. 
2. When a developer creates feature branch, above EventBridge rule would trigger Lambda function with a payload that comprises of complete repository and branch information.
3. Lambda function has been programmed in such a way that, it refers to an S3 bucket to download a CloudFormation template and creates a stack that consists of AWS CodePipeline and AWS CodeBuild project by referring to the payload information.
4. AWS CodePipeline is configured to have ‘Source’ from a repository and a feature branch that triggered the pipeline creation. 
5. AWS Codebuild project has been created referring to ‘buildspec’ file information for global or account customizations as necessary.
6. These BuildSpec files has list of instructions to fetch required details such as terraform version, terraform backend and to generate session profiles. 
7. As AFT stores the Terraform backend information for all account that are vended from AFT pipelines, it is quite easy to reconcile the terraform state file by providing account-id’s in ‘buildspec’ file for each of account customizations template.
8. AWS Codebuild project for global customization has only one stage as the IaC is common across all accounts.
9. AWS Codebuild project for account customization(in this example) has two stages as the IaC is categorized under two account templates such as workloads OU and Infrastructure OU. It can further be expanded for any ABC OU etc., 
10. IAM roles for CodePipeline and CodeBuild are provided with relevant permissions to fetch terraform state file information and able to generate Terraform Plan for the given terraform configuration.
11. While doing so, AWS CodeBuild role shall assume AFTAdmin role from AFT-Management account and generates the Terraform Execution plan by leveraging AFTExecution role in AFT Vended accounts.
12. If Terraform plan looks good, developer raises a pull request to merge ‘feature’ branch with ‘main’ branch. This gives an opportunity to review the terraform changes before triggering actual AFT pipeline for that account.
13. As a part of merge request, if ‘feature’ branch is squashed/deleted, then EventBridge rule would trigger the Lambda function which deletes of AWS CloudFormation Stack, thereby destroying the provisioned IaC pipeline for respective ‘feature’ branch.

## Usage
1. Deploy this IaC against aft-management-account.
2. Kindly pick one account-id for each workloads OU and Infrastructure OU and update them in the codebuild section of the cfn_templates/aft-feature-branch-codepipeline.yaml file.
3. Feel free to add more codebuild project incase if you have more account template folder in your account customization repositories.

## Maintainers
[SrinivasanAgile](https://github.com/SrinivasanAgile)

## Contributing
Feel free to dive in! [Open an issue](https://github.com/SrinivasanAgile/aft-feature-branch-iac-pipeline/issues/new) or [submit PRs.](https://github.com/SrinivasanAgile/aft-feature-branch-iac-pipeline/pulls)

Kindly adhere to the [Contributor Covenant](https://www.contributor-covenant.org/version/1/3/0/code-of-conduct/) Code of Conduct.

## License
[Refer License](https://github.com/SrinivasanAgile/aft-feature-branch-iac-pipeline/blob/main/LICENSE)
