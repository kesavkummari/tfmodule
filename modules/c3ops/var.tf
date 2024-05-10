variable "c3ops_vpc_id" {}

variable "c3ops_alb_internal" {}

variable "c3ops_public_subnets" { type = list}

variable "c3ops_private_subnets" { type = list}

# variable "c3ops_data_subnets" { type = list}

variable "ec2_policy_for_ssm" {}

variable "c3ops_app_ami" {
  default = ""  //Centos 7 with HVM
}


variable "c3ops_root_volume_size" {
  default = 40
}

variable "c3ops_app_instance_size" {
  default = "m4.large"
}

variable "c3ops_key_name" {}

variable "c3ops_rdp_cidrs" {
  type    = list
  default = []
}
variable "c3ops_source_cidrs" {
  type    = list
  default = ["10.0.0.0/8","3.0.0.0/8"]
}

variable "c3ops_environment" {}

variable "c3ops_ssl_certificate" {}

variable "c3ops_additional_tags" {
  type = map
}

variable "c3ops_resource_name_prepend" {
  default = "c3ops"
}

variable "c3ops_hosted_zone_id" {
  default = ""
}

variable "c3ops_setup_dns" {
  default = false
}

variable "c3ops_module_tags" {
  type = map
  default = {
    "Application"  =  "c3ops"
    "ContactEmail" =  "info@c3ops.io"
    "Business"      = "CB_TS" 
  }
}

variable "c3ops_assign_eip" {
  default = false
}

variable "c3ops_admin_linux_sg_id" {}

variable "c3ops_admin_web_sg_id" {}