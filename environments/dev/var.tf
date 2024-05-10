variable "region" {
  default = "us-east-1"
}

variable "aws_account_id" {
  default = "420815905200"
}

variable "environment" {
  default = "cb-shared-services-preprod"
}

variable "global_tags" {
  type = map(any)

  default = {
    "Customer"  = "cb-learnbydoing"
    "CreatedBy" = "terraform"
  }
}