# Azure Data Factory CI/CD with Azure DevOps

## Overview
This repo demonstrates how to deploy Azure Data Factory artifacts (pipelines, datasets, linked services, etc), through CI/CD, using an Azure DevOps pipeline.  The example Data Factory contains a single pipeline that copies blobs from one storage account to another.  All secrets used by the Data Factory are stored in a Key Vault.  All resources used by the solution (Data Factory, Storage Accounts, Key Vault and secrets) are deployed via an included [Bicep template](infrastructure/maintemplate.bicep).

## Development Workflow
Azure Data Factory has a slightly different approach to CI/CD than traditional software development.  Rather than deploying from a main/master branch as is typically done, ADF takes the approach of using a "publish" branch, typically named *adf_publish*.  This branch contains the artifacts that should be packaged and deployed across higher environments.  This repo takes the approach of using two separate Azure DevOps pipelines, one to deploy infrastructure, the Bicep template, and one to deploy the ADF artifacts.  The infrastructure pipeline is triggered off the main branch.  The ADF deploy pipeline is triggered off the adf_publish branch.

For infrastructure changes, you would create a feature branch off main and then make your changes to the Bicep template.  When the changes are merged to main, that will trigger the infrastructure deploy pipeline, pushing the changes across your environments.

For ADF changes, you would create a new feature branch via the ADF designer UI.  Once your changes are complete in the new branch, you would merge those changes back to main, and then publish those changes, via the ADF designer UI.  Publishing the changes will push them to the adf_publish branch, which will in turn trigger the ADF deploy pipeline.

## Infrastructure Pipeline
The [infrastructure pipeline](.pipelines/adf-infrastructure-deploy.yaml) is responsible for building the Bicep template and then deploying it across environments.  The build stage of the pipeline is responsible for building the template and publishing it as a pipeline artifact.  Additionally, the published artifact includes the files in the [infrastructure/parameters](infrastructure/parameters) folder.  This folder includes one file per environment, each one containing parameter values used by the Bicep template in a particular environment.  These files are named in the form of *parameters.{environmentName}.json*.  The deploy stage of the pipeline is handled through a [pipeline template](.pipelines/templates/deploy-infrastructure.yaml).  This template includes a parameter for environment name (i.e. development, production, etc).  The value of this parameter is used to resolve the correct environment-specific parameter file at deploy time.

