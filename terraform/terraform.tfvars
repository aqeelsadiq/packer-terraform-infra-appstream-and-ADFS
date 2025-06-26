
##########################
# VPC
##########################

aws_region    = "us-west-2"
resource_name = "ADFS-VPC-prod-us-west-2"
vpc_cidr      = "10.0.0.0/16"
pub_subnet = [
  {
    name              = "ADFS-Public-Subnet-1-us-west-2"
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-west-2a"
  },
  {
    name              = "ADFS-Public-Subnet-2-us-west-2"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-west-2c"
  }
]

pri_subnet = [
  {
    name              = "ADFS-Private-Subnet-1-us-west-2"
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-west-2a"
  },
  {
    name              = "ADFS-Private-Subnet-2-us-west-2"
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-west-2c"
  }
]
domain_name_servers = ["10.0.1.10"]
dhcp_domain_name    = "adfs.groveops.net"

############################
# AppStream
############################


fleet_name             = "myfleet"
stack_name             = "mystack"
instance_type_stream   = "stream.standard.medium"
appstream_image_name   = "Amazon-AppStream2-Sample-Image-06-17-2024"
organizational_unit_dn = "OU=ADFS,DC=adfs,DC=groveops,DC=net"
domain_password        = "Qw23"
domain_username        = "ADFS\\aqeel"
directory_name         = "adfs.groveops.net"
desired_instances      = 1
stream_view            = "DESKTOP"
fleet_type             = "ON_DEMAND"



#################################
# EC2 Instance
#################################

instance_type           = "t3.medium"
key_name                = "adfskey"
security_group_ec2_name = "ADFS-SAML-SG"
owners_account_id       = "489994096722"
custom_image_name       = "custom-windows-*"
private_ip              = "10.0.1.10"
hosted_zone_name        = "groveops.net"
record_name             = "adfs.groveops.net"
record_type             = "A"



# ###########################
# # IAM IdentityProvider
# ###########################
appstream_saml_role_name = "AWS-AppStream"
saml_provider_name       = "ADFS-SAMLPROVIDER"
