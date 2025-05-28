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


# CERTIFICATE COMMANDS

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
            "Resource": "arn:aws:s3:::<bucket-name>/*"
        }
    ]
}

2. Create role and attach that policy to it.
3. Attach the role with packer in file aws.pkr.hcl


