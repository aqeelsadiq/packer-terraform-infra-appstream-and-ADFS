
resource "aws_appstream_directory_config" "example" {
  directory_name = var.directory_name

  organizational_unit_distinguished_names = [
    var.organizational_unit_dn
  ]

  service_account_credentials {
    account_name     = var.domain_username
    account_password = var.domain_password
  }
}


resource "null_resource" "wait_for_directory" {
  depends_on = [aws_appstream_directory_config.example]
}


resource "aws_appstream_fleet" "this" {
  name          = var.fleet_name
  instance_type = var.instance_type_stream
  image_name    = var.appstream_image_name
  fleet_type    = var.fleet_type
  stream_view   = var.stream_view

  compute_capacity {
    desired_instances = var.desired_instances
  }

  vpc_config {
    subnet_ids         = var.subnet_id
    security_group_ids = [var.security_group_ec2_name]
  }

  domain_join_info {
    directory_name                         = aws_appstream_directory_config.example.directory_name
    organizational_unit_distinguished_name = var.organizational_unit_dn
  }

  enable_default_internet_access = true
  # disconnect_timeout_in_seconds  = 300
  # idle_disconnect_timeout_in_seconds = 600

  tags = {
    Name        = "AppStream ADFS Fleet"
    Environment = "prod"
  }

  depends_on = [aws_appstream_directory_config.example]
}

# ########################
# # AppStream Stack
# ########################
resource "aws_appstream_stack" "this" {
  name = var.stack_name

  description = "AppStream stack"

  storage_connectors {
    connector_type = "HOMEFOLDERS"
  }
  user_settings {
    action     = "AUTO_TIME_ZONE_REDIRECTION"
    permission = "DISABLED"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_FROM_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_TO_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_PASSWORD_SIGNIN"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_SMART_CARD_SIGNIN"
    permission = "DISABLED"
  }
  user_settings {
    action     = "FILE_DOWNLOAD"
    permission = "ENABLED"
  }
  user_settings {
    action     = "FILE_UPLOAD"
    permission = "ENABLED"
  }
  user_settings {
    action     = "PRINTING_TO_LOCAL_DEVICE"
    permission = "ENABLED"
  }

  application_settings {
    enabled        = true
    settings_group = "SettingsGroup"
  }
  tags = {
    Name        = "AppStream Stack"
    Environment = "prod"
  }
}

########################
# Associate Stack and Fleet
########################

resource "null_resource" "anno_associate_fleet_stack" {
  provisioner "local-exec" {
    command = "aws appstream associate-fleet --fleet-name ${aws_appstream_fleet.this.name} --stack-name ${aws_appstream_stack.this.name}"
  }

#   provisioner "local-exec" {
#     when = destroy
#     command = "aws appstream disassociateeet-fleet  ${aws_appstream_fleet.this.name} --stack-name ${aws_appstream_stack.this.name}"
#   }
}