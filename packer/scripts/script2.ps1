# -------------------------------
# Wait for Active Directory to be available
# -------------------------------
$maxRetries = 30
$retryCount = 0
while ($retryCount -lt $maxRetries) {
    try {
        Get-ADDomain > $null
        Write-Host "Active Directory is ready."
        break
    } catch {
        Write-Host "Waiting for Active Directory to start... ($retryCount)"
        Start-Sleep -Seconds 10
        $retryCount++
    }
}
if ($retryCount -eq $maxRetries) {
    throw "Active Directory did not start within expected time."
}

# -------------------------------
# Step 6: Create Users, OU, and Groups
# -------------------------------
$DomainName = "adfs.groveops.net"
$DomainDN = "DC=adfs,DC=groveops,DC=net"
$OUName = "ADFS"
$OUPath = "OU=$OUName,$DomainDN"
$User1 = "adfssvc"
$User2 = "aqeel"
$User3 = "nabeel"
$GroupName = "AWS-AppStream"
$SecurePassword = ConvertTo-SecureString "Qwerty@123" -AsPlainText -Force

# Create OU
try {
    New-ADOrganizationalUnit -Name $OUName -Path $DomainDN -ErrorAction Stop
    Write-Host "Organizational Unit '$OUName' created."
} catch {
    Write-Warning "Failed to create OU: $_"
}

# Create adfssvc user
try {
    New-ADUser -Name $User1 `
      -SamAccountName $User1 `
      -UserPrincipalName "$User1@$DomainName" `
      -GivenName "ADFS" `
      -Surname "Service" `
      -EmailAddress "$User1@$DomainName" `
      -AccountPassword $SecurePassword `
      -Enabled $true `
      -Path $OUPath
    Write-Host "User '$User1' created."
} catch {
    Write-Warning "Failed to create user '$User1': $_"
}

# Create aqeel user
try {
    New-ADUser -Name $User2 `
      -SamAccountName $User2 `
      -UserPrincipalName "$User2@$DomainName" `
      -GivenName "Aqeel" `
      -Surname "Ahmed" `
      -EmailAddress "$User2@$DomainName" `
      -AccountPassword $SecurePassword `
      -Enabled $true `
      -Path $OUPath
    Write-Host "User '$User2' created."
} catch {
    Write-Warning "Failed to create user '$User2': $_"
}


# Create nabeel user
try {
    New-ADUser -Name $User3 `
      -SamAccountName $User3 `
      -UserPrincipalName "$User3@$DomainName" `
      -GivenName "nabeel" `
      -Surname "sardar" `
      -EmailAddress "$User3@$DomainName" `
      -AccountPassword $SecurePassword `
      -Enabled $true `
      -Path $OUPath
    Write-Host "User '$User3' created."
} catch {
    Write-Warning "Failed to create user '$User3': $_"
}

# Add adfssvc to Administrators group
try {
    Add-ADGroupMember -Identity "Administrators" -Members $User1
    Write-Host "User '$User1' added to Administrators group."
} catch {
    Write-Warning "Failed to add '$User1' to Administrators group: $_"
}

# Create AWS-AppStream group
try {
    New-ADGroup -Name $GroupName `
      -SamAccountName $GroupName `
      -GroupScope Global `
      -GroupCategory Security `
      -Path $OUPath
    Write-Host "Group '$GroupName' created."
} catch {
    Write-Warning "Failed to create group '$GroupName': $_"
}

# Add aqeel to group
try {
    Add-ADGroupMember -Identity $GroupName -Members $User2
    Write-Host "User '$User2' added to group '$GroupName'."
} catch {
    Write-Warning "Failed to add '$User2' to group '$GroupName': $_"
}


# Add nabeel to group
try {
    Add-ADGroupMember -Identity $GroupName -Members $User3
    Write-Host "User '$User3' added to group '$GroupName'."
} catch {
    Write-Warning "Failed to add '$User3' to group '$GroupName': $_"
}
# -------------------------------
# Step 7: Import Certificate for ADFS
# -------------------------------
try {
    $cert = Import-PfxCertificate -FilePath "C:\Users\Administrator\Desktop\adfs.groveops.net.pfx" `
      -Password (ConvertTo-SecureString "1234" -AsPlainText -Force) `
      -CertStoreLocation "Cert:\LocalMachine\My"
    $certThumbprint = $cert.Thumbprint
    Write-Host "Certificate imported successfully. Thumbprint: $certThumbprint"
} catch {
    Write-Warning "Failed to import certificate: $_"
}

# -------------------------------
# Step 8: Configure ADFS
# -------------------------------
try {
    $adfsCredential = New-Object System.Management.Automation.PSCredential("ADFS\$User1", $SecurePassword)

    Install-AdfsFarm `
      -CertificateThumbprint $certThumbprint `
      -FederationServiceDisplayName "GroveOps ADFS" `
      -FederationServiceName "adfs.groveops.net" `
      -ServiceAccountCredential $adfsCredential

    Write-Host "ADFS farm installed successfully."
} catch {
    Write-Warning "Failed to configure ADFS: $_"
}

# -------------------------------
# Step 9: Set SPNs for ADFS Service Account
# -------------------------------
try {
    setspn -s host/adfs.groveops.net $User1
    setspn -s http/adfs.groveops.net $User1
    Set-AdfsProperties -EnableRelayStateForIdpInitiatedSignOn $true
    Set-ADFSProperties -EnableIdpInitiatedSignonPage $true
    Write-Host "SPNs configured and ADFS sign-on page enabled."
} catch {
    Write-Warning "Failed to set SPNs or configure ADFS properties: $_"
}

# -------------------------------
# Step 10: Configure IIS HTTPS Binding
# -------------------------------
$siteName = "Default Web Site"
$certStore = "MY"
$ip = "*"
$port = 443
$hostname = ""

try {
    Import-Module WebAdministration

    # Add HTTPS binding to the site
    New-WebBinding -Name $siteName -Protocol https -Port $port -IPAddress $ip -HostHeader $hostname

    # Bind certificate to the new binding
    Push-Location IIS:\SslBindings

    if (-not (Test-Path "$ip!$port")) {
        New-Item "$ip!$port" -Thumbprint $certThumbprint -SSLFlags 0
        Write-Host "SSL certificate bound to $siteName on port $port."
    } else {
        Write-Host "Binding already exists at ${ip}:${port}"
    }

    Pop-Location
} catch {
    Write-Warning "Failed to bind SSL certificate to IIS: $_"
}

# -------------------------------
# Step 11: Restart ADFS Service
# -------------------------------
try {
    Restart-Service adfssrv
    Write-Host "ADFS service restarted successfully."
} catch {
    Write-Warning "Failed to restart ADFS service: $_"
}


