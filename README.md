# CI/CD Codebuild Terraform Backend

This solution provides an execution backend for terraform templates to support multiple developers releasing infrastructure changes from dev to test and prod environments.

## User Guide

This document contains usage instructions and step-by-step guides to operate automated terraform deployments for dev, test and production environments using codebuild.

## Application Account Onboarding

Once an AWS Account is provisioned and accessible by application developers, the terraform backend can be configured in the account with the steps below.

### Create terraform build project in a New Account

This guide assumes that one AWS Account is used for one stage of one application, if that is not the case, adjust parameters accordingly.

**1 - Collect pre-requisite information and request account access:**

	a. Account ID.
	b. Access to InfraDevOps role
	c. Stage name (dev|test|prod)
	d. Application name
	e. Application Terraform Source repository URL (ALM GITHUB)

**2 - Deploy Pipeline configuration**

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
	
f.1. Take note of execution output: "backend_bucket_name" and the bucket region

```
		backend_bucket_name: pipeline-<stage>-<app-name>-<random_string>
		bucket_region:       us-east-1
```

f.2. Uncomment and complete the variables.tf file (terraform variables can't be used here)

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

f.3. Initialize and migrate state to S3 backend.

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

f.4. Enter "yes" to migrate the state to the S3 backend

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

**3. Configure the application terraform backend and workspace.**

a. Clone Application terraform repository

```
	$ git clone https://<source_location> 
``` 

b. Configure Terraform backend, by adding the following snippet to the root's module variables.tf file, using the S3 bucket created by the codebuild template.

```
	terraform {
	  backend "s3" {
	    bucket = "<bucket_name>"
	    key    = "terraform_state_files/<app_name>.tfstate"
	    region = "us-east-1"
	  }
	} 
``` 

c. Initialize terraform backend

```
	$ cd <App_repo> 
	$ terraform init
``` 

c. Create workspace for new stage.

```
	$ terraform workspace new <stage>
```

c. Push changes to repository.

```
	$ git add variables.tf
	$ git commit -m "Adds S3 backend configuration for <dev|test|prod> stage"
	$ git push origin master
```

**4. Completed! run the first build to confirm the application stack is successfully deployed.**

a. Login to the AWS Console for the corresponding account with the InfraDevOps role

b. Navigate to AWS CodeBuild -> CodeBuild Projects -> <App-name>-<stage>

c. Run Build, and enjoy! 

### Create terraform pipeline for a New Stage in existing account

If the account was already onboarded with one application stage, but a new application or application stage will be also hosted in the account, complete the onboarding of the pipeline following these steps.

**1 - Collect pre-requisite information and request account access:**

	a. Account ID.
	b. Access to InfraDevOps role
	c. Stage name (dev|test|prod)
	d. Application name
	e. Application Terraform Source repository URL (ALM GITHUB)

**2 - Deploy Pipeline configuration**

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

**3. Configure the application terraform backend and workspace.**

a. Clone Application terraform repository

```
	$ git clone https://<source_location> 
``` 

b. Configure Terraform backend, by adding the following snippet to the root's module variables.tf file, using the S3 bucket created by the codebuild template.

```
	terraform {
	  backend "s3" {
	    bucket = "<bucket_name>"
	    key    = "terraform_state_files/<app_name>.tfstate"
	    region = "us-east-1"
	  }
	} 
``` 

c. Initialize terraform backend

```
	$ cd <App_repo> 
	$ terraform init
``` 

c. Create workspace for new stage.

```
	$ terraform workspace new <stage>
```

c. Push changes to repository.

```
	$ git add variables.tf
	$ git commit -m "Adds S3 backend configuration for <dev|test|prod>"
	$ git push origin master
```

**4. Completed! run the first build to confirm the application stack is successfully deployed.**

a. Login to the AWS Console for the corresponding account with the InfraDevOps role

b. Navigate to AWS CodeBuild -> CodeBuild Projects -> <App-name>-<stage>

c. Run Build, and enjoy!

## Terraform State Backend, Workspaces & Stages

This execution backend requires the usage of S3 state backed to persist terraform states between different build runs. The application template must configure the backend property, tipically at the topmost of the root variables.tf file, with a snippet like:

```
terraform {
  backend "s3" {
    bucket = "<bucket name>"
    key    = "terraform/<app name>.tfstate"
    region = "us-east-1"
  }
} 
```

A stage is a name that identifies an environment for deployment, normally shortned "dev" for development environments, test for Operational/User Acceptance testing environment and "prod" for Production.

The backend and the workspace must be initialized prior to executing a build in the pipeline, after saving the configuration in the file, run init and workspace new <stage> to initialize the state backend and to create the workspace. for example for "dev" stage

```
$ terraform init
$ terraform workspace new dev
```

This template receives the stage as a parameter, and configures an environmental variable in the CodeBuild Project with the value, accessible in the build script as $STAGE, and can be set in the codebuild script using the workspace select command.

```
$ terraform workspace select $STAGE
```

See the Buildspec section below for a complete buildspec.yaml example. 

## Terraform variables

The build should invoke terraform using a variable file, with the name for the corresponding stage, using the -var-file parameter for terraform. 
Variable files should be available under the "/variables" directory in the template source root. and the build script should invoke terraform plan with the corresponding file for the stage, for example in dev:

```
$ terraform plan -var-file="variables/dev.tfvars" -out="tfplan"
```

in codebuild, the script can autocomplete to name of the stage from the environmental variable $STAGE configured for the project.

```
$ terraform plan -var-file="variables/$STAGE.tfvars" -out="tfplan"
```

The "tfplan" file generated contains the execution plan for that particular set of input variables, and is executed with the apply command.

```
$ terraform apply "tfplan"
```

## Application's CodeBuild Buildspec

Each application template will package together with terraform code a buildspec.yaml file with the recipe to execute the template in the appropriate workspace and variable file.

Pipeline automation imposes mandatory guidelines for buildspec.yaml definition for this terraform backend, the script must execute the steps:

  1. Install Terraform binary
  2. Init terraform backend
  3. Select appropriate Stage workspace
  4. Validate Terraform template syntax
  5. Generate Terraform plan
  6. Apply Terraform plan

To correctly implement the steps above, include this steps in the app's buildspec.yaml file, and add it to the root directory of the terraform repository.

```
phases:
  install:
  	commands:
      - apt-get install wget unzip
      - wget -q https://releases.hashicorp.com/terraform/0.12.10/terraform_0.12.10_linux_amd64.zip -O terraform.zip
      - unzip ./terraform.zip -d /usr/local/bin/
  build:
  	commands:
      - terraform init
      - terraform workspace select $STAGE
      - terraform validate 
      - terraform plan -var-file="variables/$STAGE.tfvars" -out="tfplan"
      - terraform apply "tfplan"

```

## CodeBuild backend Stage variables

Pipeline automation mandetes that stage variables are stored in a variable template file, in the application terraform code repo, in a directory /variables. The file name must be the same as the stage idetifier. If the stage identifier is "dev" the variable file must be /variables/dev.tfvars. One file is mandatory for each active stage.

## Pipeline Operations
### Run New Deployments
TODO
### Releases & Changes
TODO
### Workspaces & Stages
TODO
### Stack termination
TODO
