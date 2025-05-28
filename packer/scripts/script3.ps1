# Load the ADFS module
Import-Module ADFS

############### AWS Console Trust ################

Write-Host "Creating AWS Console relying party trust..."

# Variables
$displayName = "AWS-console"
$identifier = "https://signin.aws.amazon.com/saml"
$ssoUrl = "https://signin.aws.amazon.com/saml"
$groupName = "AWS-AppStream"

# Create a SAML endpoint
$samlEndpoint = New-AdfsSamlEndpoint -Binding POST -Protocol SAMLAssertionConsumer -Uri $ssoUrl

# Create the relying party trust
Add-AdfsRelyingPartyTrust `
    -Name $displayName `
    -Identifier $identifier `
    -SamlEndpoint $samlEndpoint `
    -ProtocolProfile "SAML" `
    -IssuanceAuthorizationRules '=> issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");'

# Define Claim Rules
$claimRule1 = @"
@RuleTemplate = "MapClaims"
@RuleName = "NameID"
c:[Type ==
"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"]
=> issue(Type =
"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", Issuer
= c.Issuer, OriginalIssuer = c.OriginalIssuer, Value = c.Value, ValueType = c.ValueType, Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] = "urn:oasis:names:tc:SAML1.1:nameid format:unspecified");
"@                                   
                                       
                                                    
$claimRule2 = @"                    
@RuleTemplate = "LdapClaims"
@RuleName = "RoleSessionName"
c:[Type ==
"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname",
Issuer == "AD AUTHORITY"]
=> issue(store = "Active Directory", types =
("https://aws.amazon.com/SAML/Attributes/RoleSessionName"), query =
";mail;{0}", param = c.Value);
"@                              
                                  

$claimRule3 = @"
@RuleName = "ADGroups"                                                                                                  
c:[Type ==                                                                                                              
"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname",                                           
Issuer == "AD AUTHORITY"]                                                                                                
=> add(store = "Active Directory", types = ("http://temp/variable"), query =                                           
";tokenGroups;{0}", param = c.Value);
"@                                    
                                       
                                       
$claimRule4 = @"                                 
@RuleName = "Roles"                                                                                                     
c:[Type == "http://temp/variable", Value =~ "(?i)^AWS-"]                                                                 
=> issue(Type = "https://aws.amazon.com/SAML/Attributes/Role", Value =                                                 
RegExReplace(c.Value, "AWS-", "arn:aws:iam::489994096722:saml-provider/ADFS-SAMLPROVIDER,arn:aws:iam::489994096722:role/AWS-"));                                     
"@

Set-AdfsRelyingPartyTrust -TargetName $displayName -IssuanceTransformRules ($claimRule1 + "`n" + $claimRule2 + "`n" + $claimRule3 + "`n" + $claimRule4)

Write-Host "AWS Console trust configured."

############### AppStream Trust ################

Write-Host "Creating AppStream relying party trust..."

# Variables
$displayName = "AWS-AppStream"
$identifier = "https://appstream2.us-west-2.aws.amazon.com/saml"
$ssoUrl = "https://appstream2.us-west-2.aws.amazon.com/saml?stack=mystack&accountId=489994096722"
$groupName = "AWS-AppStream"

# Create a SAML endpoint
$samlEndpoint = New-AdfsSamlEndpoint -Binding POST -Protocol SAMLAssertionConsumer -Uri $ssoUrl

# Create the relying party trust
Add-AdfsRelyingPartyTrust `
    -Name $displayName `
    -Identifier $identifier `
    -SamlEndpoint $samlEndpoint `
    -ProtocolProfile "SAML" `
    -IssuanceAuthorizationRules '=> issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");'

# Define Claim Rules
$claimRule1 = @"
@RuleTemplate = "MapClaims"
@RuleName = "NameID"
c:[Type ==
"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"]
=> issue(Type =
"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", Issuer
= c.Issuer, OriginalIssuer = c.OriginalIssuer, Value = c.Value, ValueType = c.ValueType, Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] = "urn:oasis:names:tc:SAML1.1:nameid format:unspecified");
"@                                   
                                    
$claimRule2 = @"                    
@RuleTemplate = "LdapClaims"
@RuleName = "RoleSessionName"
c:[Type ==
"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname",
Issuer == "AD AUTHORITY"]
=> issue(store = "Active Directory", types =
("https://aws.amazon.com/SAML/Attributes/RoleSessionName"), query =
";mail;{0}", param = c.Value);
"@                              
                                  
$claimRule3 = @"
@RuleName = "ADGroups"                                                                                                  
c:[Type ==                                                                                                              
"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname",                                           
Issuer == "AD AUTHORITY"]                                                                                                
=> add(store = "Active Directory", types = ("http://temp/variable"), query =                                           
";tokenGroups;{0}", param = c.Value);
"@                                    
                                                                         
$claimRule4 = @"                                 
@RuleName = "Roles"                                                                                                     
c:[Type == "http://temp/variable", Value =~ "(?i)^AWS-"]                                                                 
=> issue(Type = "https://aws.amazon.com/SAML/Attributes/Role", Value =                                                 
RegExReplace(c.Value, "AWS-", "arn:aws:iam::489994096722:saml-provider/ADFS-SAMLPROVIDER,arn:aws:iam::489994096722:role/AWS-"));                                     
"@

Set-AdfsRelyingPartyTrust -TargetName $displayName -IssuanceTransformRules ($claimRule1 + "`n" + $claimRule2 + "`n" + $claimRule3 + "`n" + $claimRule4)

Write-Host "AppStream trust configured."

############### Restart ADFS Once at the End ################

Write-Host "Restarting ADFS to apply changes..."
Restart-Service adfssrv

Write-Host "All relying party trusts and claim rules have been created and ADFS service restarted."