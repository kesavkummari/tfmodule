# Stat File
terraform {
  required_version = "1.5.7"
  backend "s3" {
    bucket = "cb-iac-terraform"
    key    = "accounts/cb-shared-services/terraform.tfstate"
    region = "us-east-1"
    #dynamodb_table = "cb-iac-terraform"
    role_arn   = "arn:aws:iam:::role/terraform-automation"
  }
}

# Providers 
provider "aws" {
  assume_role {
    role_arn   = "arn:aws:iam::${var.aws_account_id}:role/terraform-automation"
  }
  region = var.region
  # version = "5.48.0"
  #profile = "default"
}

data "terraform_remote_state" "shared_services_account" {
  backend = "s3"

  config = {
    profile = "suez-shared-services"
    bucket  = "cb-iac-terraform"
    key     = "accounts/cb-shared-services/terraform.tfstate"
    region  = "us-east-1"
  }
}

module "c3ops_prod" {
  source = "../../modules/c3ops/"
    #source = "/Users/ck/repos/c3ops-portal-terraform/modules/c3ops/"

  # App Instance Inputs
  c3ops_vpc_id          = data.terraform_remote_state.shared_services_account.outputs.cb_shared_services_vpc.vpc_id
  c3ops_public_subnets  = data.terraform_remote_state.shared_services_account.outputs.cb_shared_services_vpc.public_subnets
  c3ops_private_subnets = data.terraform_remote_state.shared_services_account.outputs.cb_shared_services_vpc.private_subnets
  # c3ops_data_subnets      = module.terraform_remote_state.outputs.data_subnets
  ec2_policy_for_ssm      = data.terraform_remote_state.shared_services_account.outputs.ec2_policy_for_ssm
  c3ops_additional_tags   = var.global_tags
  c3ops_environment       = "prod"
  c3ops_ssl_certificate   = "arn:aws:acm:us-east-1:420815905200:certificate/9209f635-d9dc-467e-b854-8344d883c6c4"
  c3ops_key_name          = "shared_services_admin"
  c3ops_admin_linux_sg_id = data.terraform_remote_state.shared_services_account.outputs.cb_shared_services_linux_sg
  c3ops_admin_web_sg_id   = data.terraform_remote_state.shared_services_account.outputs.cb_shared_services_web_sg
  c3ops_app_instance_size = "t2.micro"
  c3ops_alb_internal      = "true" //Set this as true if you want an Internal ALB, false if you want a Public ALB
}