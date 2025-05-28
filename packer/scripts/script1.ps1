# -------------------------------
# Step 1: Install Required Windows Features
# -------------------------------

Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name ADFS-Federation -IncludeManagementTools
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# -------------------------------
# Step 2: Install AWS CLI
# -------------------------------

# Download AWS CLI installer
Invoke-WebRequest "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "$env:TEMP\AWSCLIV2.msi"

# Install AWS CLI silently
Start-Process msiexec.exe -Wait -ArgumentList '/i', "$env:TEMP\AWSCLIV2.msi", '/quiet'

# Permanent PATH update (machine-wide)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Amazon\AWSCLIV2\", [System.EnvironmentVariableTarget]::Machine)

# Update current session PATH so aws command works without restarting
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2\"

# -------------------------------
# Step 3: Download ADFS Certificate from S3
# -------------------------------

aws s3 cp s3://certificate-for-adfs-ec2instance/adfs.groveops.net.pfx C:\Users\Administrator\Desktop\ --region us-west-2


# -------------------------------
# Step 4: Configure Active Directory Domain Services
# -------------------------------

$DomainName = "adfs.groveops.net"
$SafeModePassword = ConvertTo-SecureString "Qwerty@123" -AsPlainText -Force

Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDNS `
    -Force
