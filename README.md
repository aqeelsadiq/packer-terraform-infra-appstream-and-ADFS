# packer-terraform-infra-appstream-and-ADFS
This project automates the provisioning of a Windows Server environment with Active Directory, ADFS, and Amazon AppStream 2.0 using Packer and Terraform.


# Prerequisites
1. AWS CLI & credentials configured
2. Terraform v1.5+
3. Packer v1.9+
4. PowerShell
5. A valid .pfx certificate for ADFS
6. A hosted zone if using custom DNS (e.g groveops.net)
7. Role for Packer to fetch the certificate from s3.


# Certificate Commands

1- ```sudo apt install certbot```

2- ```sudo certbot certonly --manual --preferred-challenges dns --register-unsafely-without-email -d adfs.groveops.net```

after that it show the TXT record go to the Route53 select hosted zone and create record and enter TXT value that appear
after 1 to 5 minutes press enter 

3- ```sudo openssl pkcs12 -export   -out ~/adfs.groveops.net.pfx   -inkey /etc/letsencrypt/live/adfs.groveops.net/privkey.pem   -in /etc/letsencrypt/live/adfs.groveops.net/fullchain.pem   -certfile /etc/letsencrypt/live/adfs.groveops.net/chain.pem```

enter password. and keep the password secure.


1. create policy

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket-name/*"
    }
  ]
}

2. Create role and attach that policy to the role.
3. attch the role with packer aws.pkr.hcl

# Packer Overview
**aws.pkr.hcl**

Defines the AMI build:
1. Starts with a base Windows Server 2022 AMI.
2. Uses bootstrap_win.txt to enable WinRM.
3. Runs PowerShell scripts under scripts/.

**Scripts**
1. script1.ps1: Active Directory domain setup and awscli download.
2. script2.ps1: create Active Directory Users and group.
3. script3.ps1: Create relying party trust.


# Terraform Overview
**Modules**

vpc/
1. Provisions VPC, subnets, route tables, and security groups.
2. Includes SSL certificate file: adfs.groveops.net.pfx.

ec2/
1. Launches EC2 instance using the AMI built by Packer.

iam-samlprovider/
1. Configures IAM identity provider using FederationMetadata.xml.

appstream/
1. Deploys AppStream 2.0 fleet and stack.
2. Integrates with domain-joined EC2.


# How to Use
1. Build the AMI with Packer

cd packer
1. packer init .
2. packer validate .
3. packer build aws.pkr.hcl

2. Deploy Infrastructure with Terraform

cd terraform
1. terraform init
2. terraform plan
3. terraform apply

