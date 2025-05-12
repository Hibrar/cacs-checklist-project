# Setting up the minimum Terraform version
terraform {
  required_version = ">= 1.0.0"
# Configuring Terraform Cloud settings
  cloud {
    organization = "cacs-checklist-project"
    workspaces {
      name = "cacs-checklist-project" #Workspace setup yo use within Terraform Cloud
    }
  }
  #Specifying the required providers and versions
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
#Configuring AWS provider to London region
provider "aws" {
  region = "eu-west-2"
}


module "cacs_checklist_module" {
  source      = "./Modules"

  # db_username = var.db_username
  # db_password = var.db_password
  api_token   = var.api_token
  ssh_private_key  = var.ssh_private_key
}
