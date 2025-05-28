####1. SAML Identity Provider (replace with your real metadata file)
resource "aws_iam_saml_provider" "adprovider" {
  name                   = var.saml_provider_name
  saml_metadata_document = file("${path.module}/FederationMetadata.xml")
}

# 2. IAM Role for SAML Federation with AppStream-only permissions
resource "aws_iam_role" "saml_appstream_role" {
  name = var.appstream_saml_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_saml_provider.adprovider.arn
        },
        Action = "sts:AssumeRoleWithSAML",
        Condition = {
          StringEquals = {
            "SAML:aud" = "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "appstream_access" {
  role       = aws_iam_role.saml_appstream_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAppStreamFullAccess"
}