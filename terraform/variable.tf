##########################
# VPC
##########################

variable "aws_region" {}
variable "resource_name" {}
variable "vpc_cidr" {}
variable "pub_subnet" {
  type = list(map(string))
}
variable "pri_subnet" {
  type = list(map(string))
}
variable "dhcp_domain_name" {}

############################
# AppStream
############################

variable "fleet_name" {}
variable "stack_name" {}
variable "instance_type_stream" {}
variable "appstream_image_name" {}
variable "organizational_unit_dn" {
}
variable "domain_password" {
  type = string
}
variable "domain_username" {
  type = string
}
variable "directory_name" {}
variable "fleet_type" {}
variable "stream_view" {}
variable "desired_instances" {}
variable "domain_name_servers" {}





#################################
# EC2 Instance
#################################

variable "instance_type" {}
variable "key_name" {}
variable "owners_account_id" {}
variable "custom_image_name" {}
variable "private_ip" {}
variable "hosted_zone_name" {}
variable "record_name" {}
variable "record_type" {}
variable "security_group_ec2_name" {}

# ###########################
# # IAM IdentityProvider
# ###########################

variable "appstream_saml_role_name" {}
variable "saml_provider_name" {}
