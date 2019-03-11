provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.mgmt_acct_id}:role/OrganizationAccountAccessRole"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
