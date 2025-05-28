variable "vpc_cidr" {}
variable "resource_name" {}
variable "pub_subnet" {
  type = list(map(string))
}
variable "pri_subnet" {
  type = list(map(string))
}
variable "aws_region" {}
variable "domain_name_servers" {}
variable "dhcp_domain_name" {}