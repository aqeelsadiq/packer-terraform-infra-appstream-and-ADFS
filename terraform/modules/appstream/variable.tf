variable "fleet_name" {}
variable "stack_name" {}
variable "instance_type_stream" {}
variable "appstream_image_name" {}
variable "organizational_unit_dn" {}
variable "domain_password" {
  type = string
}
variable "domain_username" {
  type = string
}
variable "subnet_id" {}
variable "security_group_ec2_name" {}
variable "directory_name" {}
variable "fleet_type" {}
variable "stream_view" {}
variable "desired_instances" {}

