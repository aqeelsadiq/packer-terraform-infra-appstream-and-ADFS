packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0, < 2.0.0"
    }
  }
}

variable "ami_name" {
  type = string
  default = "custom-windows-{{timestamp}}"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

# https://www.packer.io/docs/builders/amazon/ebs
source "amazon-ebs" "windows" {
  ami_name = "${var.ami_name}"
  instance_type = "t3.medium"
  region = "${var.region}"
  source_ami_filter {
    filters = {
      name = "Windows_Server-2022-English-Full-Base-*"
      root-device-type = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = ["amazon"]
  }
  communicator = "winrm"
  winrm_username = "Administrator"
  winrm_use_ssl = true
  winrm_insecure = true
  iam_instance_profile = "adfs-get-object"
  associate_public_ip_address = true     #when using custom vpc


  # This user data file sets up winrm and configures it so that the connection
  # from Packer is allowed. Without this file being set, Packer will not
  # connect to the instance.
  user_data_file = "bootstrap_win.txt"

 #vpc_id                 = "vpc-"
 #subnet_id              = "subnet-"
 # security_group_id       = "sg-"
}

# https://www.packer.io/docs/provisioners
build {
  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    scripts = [
      "scripts/script1.ps1"
    ]
  }


  provisioner "powershell" {
    scripts = [
      "scripts/script2.ps1",
      "scripts/script3.ps1"
    ]
  }
}
