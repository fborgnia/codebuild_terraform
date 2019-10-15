# CI/CD Codebuild Terraform Backend User Guide

This document contains usage instructions and step-by-step guides to operate automated terraform deployments for dev, test and production environments.

## Application Account Onboarding

Once the AWS Account are provisioned and accessible by application developers, the terraform backend can be configured in the account with this steps.

### Create New Account

This guide assumes that one AWS Account is used for one stage of one application, if that is not the case, adjust parameters accordingly.

1 - Collect pre-requisite information and request account access:
	a. Account ID.
	b. Access to InfraDevOps role
	c. Stage name (dev|test|prod)
	d. Application name
	e. Application Terraform Source repository URL (ALM GITHUB)

2 - Deploy Pipeline configuration
a. Complete stage variable file in variables/<stage>.tfvars
```
		stage = "dev|test|prod"
		name = "example-app"
		source_location = "https://github.com/fborgnia/example_app.git"
```

b. Validate terraform template

```
		$ terraform validate -var-file="variables/<stage>.tfvars"
```
	c. Create terraform backend and workspace for the stage
```
		$ terraform init
		$ terraform workspace new <stage>
```
	d. Create terraform plan & review deployment
```
		$ terraform plan -var-file="variables/<stage>.tfvars" -out="tfplan"
```
   	e. Apply the plan
```
		$ terraform apply tfplan
```
   	f. Update the terraform backend configuration to persist the state in S3

   		1. Take note of execution output: "backend_bucket_name" and the bucket region
```
			backend_bucket_name: pipeline-<stage>-<app-name>-<random_string>
			bucket_region:       us-east-1
```
		2. Uncomment and complete the variables.tf file (terraform variables can't be used here)
		from:
```
			#terraform {
			#  backend "s3" {
			#    bucket = ""
			#    key    = ""
			#    region = ""
			#  }
			#}
```
		to:
```
			terraform {
			  backend "s3" {
			    bucket = "pipeline-dev-example-app-ulwydhpc"
			    key    = "terraform_state_files/example_app.tfstate"
			    region = "us-east-1"
			  }
			}
```
		3. Initialize and migrate state to S3 backend.
```
			$ terraform init
			Initializing modules...

			Initializing the backend...
			Backend configuration changed!

			Terraform has detected that the configuration specified for the backend
			has changed. Terraform will now check for existing state in the backends.


			Do you want to migrate all workspaces to "s3"?
			  Both the existing "s3" backend and the newly configured "s3" backend
			  support workspaces. When migrating between backends, Terraform will copy
			  all workspaces (with the same names). THIS WILL OVERWRITE any conflicting
			  states in the destination.

			  Terraform initialization doesn't currently migrate only select workspaces.
			  If you want to migrate a select number of workspaces, you must manually
			  pull and push those states.

			  If you answer "yes", Terraform will migrate all states. If you answer
			  "no", Terraform will abort.

			  Enter a value:
```
			Enter "yes" to migrate the state to the S3 backend
```
			Successfully configured the backend "s3"! Terraform will automatically
			use this backend unless the backend configuration changes.

			Initializing provider plugins...

			The following providers do not have any version constraints in configuration,
			so the latest version was installed.

			To prevent automatic upgrades to new major versions that may contain breaking
			changes, it is recommended to add version = "..." constraints to the
			corresponding provider blocks in configuration, with the constraint strings
			suggested below.

			* provider.aws: version = "~> 2.32"
			* provider.random: version = "~> 2.2"

			Terraform has been successfully initialized!

			You may now begin working with Terraform. Try running "terraform plan" to see
			any changes that are required for your infrastructure. All Terraform commands
			should now work.

			If you ever set or change modules or backend configuration for Terraform,
			rerun this command to reinitialize your working directory. If you forget, other
			commands will detect it and remind you to do so if necessary.
```
	g. Completed! run the first build to confirm the application stack is successfully deployed.

### Create New Stage in existing account

If the account was already onboarded with one application stage, but a new application or application stage will be also hosted in the account, complete the onboarding of the pipeline following these steps.

1 - Collect pre-requisite information and request account access:
	a. Account ID.
	b. Access to InfraDevOps role
	c. Stage name (dev|test|prod)
	d. Application name
	e. Application Terraform Source repository URL (ALM GITHUB)

2 - Deploy Pipeline configuration
	a. Complete stage variable file in variables/<stage>.tfvars
```
		stage = "dev|test|prod"
		name = "example-app"
		source_location = "https://github.com/fborgnia/example_app.git"
```
	b. Validate terraform template
```
		$ terraform validate -var-file="variables/<stage>.tfvars"
```
	c. Initialize terraform backend and create workspace for the stage
```
		$ terraform init
		$ terraform workspace new <stage>
```
	d. Create terraform plan & review deployment
```
		$ terraform plan -var-file="variables/<stage>.tfvars" -out="tfplan"
```
   	e. Apply the plan
```
		$ terraform apply tfplan
```
   	f. Update the terraform backend configuration to persist the state in S3

   		1. Take note of execution output: "backend_bucket_name" and the bucket region
```
			backend_bucket_name: pipeline-<stage>-<app-name>-<random_string>
			bucket_region:       us-east-1
```
		2. Uncomment and complete the variables.tf file (terraform variables can't be used here)
		from:
```
			#terraform {
			#  backend "s3" {
			#    bucket = ""
			#    key    = ""
			#    region = ""
			#  }
			#}
```
		to:
```
			terraform {
			  backend "s3" {
			    bucket = "pipeline-dev-<app-name>-ulwydhpc"
			    key    = "terraform_state_files/<app_name>.tfstate"
			    region = "us-east-1"
			  }
			}
```
		3. Initialize and migrate state to S3 backend.
```
			$ terraform init
			Initializing modules...

			Initializing the backend...
			Backend configuration changed!

			Terraform has detected that the configuration specified for the backend
			has changed. Terraform will now check for existing state in the backends.


			Do you want to migrate all workspaces to "s3"?
			  Both the existing "s3" backend and the newly configured "s3" backend
			  support workspaces. When migrating between backends, Terraform will copy
			  all workspaces (with the same names). THIS WILL OVERWRITE any conflicting
			  states in the destination.

			  Terraform initialization doesn't currently migrate only select workspaces.
			  If you want to migrate a select number of workspaces, you must manually
			  pull and push those states.

			  If you answer "yes", Terraform will migrate all states. If you answer
			  "no", Terraform will abort.

			  Enter a value:
```
			Enter "yes" to migrate the state to the S3 backend
```
			Successfully configured the backend "s3"! Terraform will automatically
			use this backend unless the backend configuration changes.

			Initializing provider plugins...

			The following providers do not have any version constraints in configuration,
			so the latest version was installed.

			To prevent automatic upgrades to new major versions that may contain breaking
			changes, it is recommended to add version = "..." constraints to the
			corresponding provider blocks in configuration, with the constraint strings
			suggested below.

			* provider.aws: version = "~> 2.32"
			* provider.random: version = "~> 2.2"

			Terraform has been successfully initialized!

			You may now begin working with Terraform. Try running "terraform plan" to see
			any changes that are required for your infrastructure. All Terraform commands
			should now work.

			If you ever set or change modules or backend configuration for Terraform,
			rerun this command to reinitialize your working directory. If you forget, other
			commands will detect it and remind you to do so if necessary.
```
	g. Completed! run the first build to confirm the application stack is successfully deployed.

## CodeBuild Buildspec requirements

Pipeline automation imposes mandatory guidelines for buildspec.yaml definition for this terraform backend, the script must execute the steps:

  1. Install Terraform binary
  2. Init terraform backend
  3. Select appropriate Stage workspace
  4. Validate Terraform template syntax
  5. Generate Terraform plan
  6. Apply Terraform plan

To correctly implement the steps above, complete your application buildspec.yaml file with the snippet below, and add it to the root directory of the terraform repository.

```
phases:
  build:
    commands:
      - apt-get install wget unzip
      - wget -q https://releases.hashicorp.com/terraform/0.12.10/terraform_0.12.10_linux_amd64.zip -O terraform.zip
      - unzip ./terraform.zip -d /usr/local/bin/
      - terraform init
      - terraform workspace select $STAGE
      - terraform validate 
      - terraform plan -var-file="variables/$STAGE.tfvars" -out="tfplan"
      - terraform apply "tfplan"

```

## CodeBuild backend Stage variables

Pipeline automation mandetes that stage variables are stored in a variable template file, in the application terraform code repo, in a directory /variables. The file name must be the same as the stage idetifier. If the stage identifier is "dev" the variable file must be /variables/dev.tfvars. One file is mandatory for each active stage.

## Pipeline Operations
### New Deployments
### Releases & Changes
### Workspaces & Stages
### Stack termination
