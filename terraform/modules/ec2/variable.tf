variable "instance_type" {}
variable "vpc_id" {}
variable "pub_subnet" {}
variable "key_name" {}
variable "security_group_ec2_name" {}

variable "role_name" {
  type        = string
  default     = "DomainjoinRole"
  description = "IAM Role name"
}

variable "trusted_role_services" {
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
  description = "Trusted AWS services for assume role"
}

variable "tags" {
  type = map(string)
  default = {
    Name        = "DomainjoinRole"
    Environment = "prod"
  }
}
variable "owners_account_id" {}
variable "custom_image_name" {}
variable "private_ip" {}
variable "hosted_zone_name" {}
variable "record_name" {}
variable "record_type" {}

