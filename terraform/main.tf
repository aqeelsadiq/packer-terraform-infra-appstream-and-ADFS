
##########################
# VPC
##########################

module "vpc" {
  source              = "./modules/vpc"
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  resource_name       = var.resource_name
  pub_subnet          = var.pub_subnet
  pri_subnet          = var.pri_subnet
  domain_name_servers = var.domain_name_servers
  dhcp_domain_name    = var.dhcp_domain_name
}


############################
# AppStream
############################

module "appstream" {
  source                  = "./modules/appstream"
  fleet_name              = var.fleet_name
  stack_name              = var.stack_name
  instance_type_stream    = var.instance_type_stream
  appstream_image_name    = var.appstream_image_name
  organizational_unit_dn  = var.organizational_unit_dn
  domain_password         = var.domain_password
  domain_username         = var.domain_username
  subnet_id               = module.vpc.pub_subnet
  security_group_ec2_name = module.ec2.security_group_id
  directory_name          = var.directory_name
  fleet_type              = var.fleet_type
  stream_view             = var.stream_view
  desired_instances       = var.desired_instances
  depends_on              = [module.ec2]

}


#################################
# EC2 Instance
#################################

module "ec2" {
  source                  = "./modules/ec2"
  instance_type           = var.instance_type
  vpc_id                  = module.vpc.vpc_id
  pub_subnet              = module.vpc.pub_subnet
  key_name                = var.key_name
  security_group_ec2_name = var.security_group_ec2_name
  owners_account_id       = var.owners_account_id
  custom_image_name       = var.custom_image_name
  private_ip              = var.private_ip
  hosted_zone_name        = var.hosted_zone_name
  record_name             = var.record_name
  record_type             = var.record_type
}


# ###########################
# # IAM IdentityProvider
# ###########################

module "iam-samlprovider" {
  source                   = "./modules/iam-samlprovider"
  appstream_saml_role_name = var.appstream_saml_role_name
  saml_provider_name       = var.saml_provider_name
}
