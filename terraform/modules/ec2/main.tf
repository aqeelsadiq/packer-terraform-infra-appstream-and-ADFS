##########################
# EC2Instance
##########################


data "aws_ami" "adfs_windows" {
  most_recent = true
  owners      = [var.owners_account_id]

  filter {
    name   = "name"
    values = [var.custom_image_name]
  }
}

resource "aws_instance" "webserver" {
  ami                         = data.aws_ami.adfs_windows.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.vote_service_sg.id]
  subnet_id                   = var.pub_subnet[0]
  key_name                    = var.key_name
  associate_public_ip_address = true
  private_ip                  = var.private_ip
  # iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name        = "ADFS-DomainJoin-Instance"
    Environment = "prod"
  }
}


#####################################
#Security Group
###################################
resource "aws_security_group" "vote_service_sg" {
  name   = var.security_group_ec2_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = [
      { desc = "RDP", from = 3389, to = 3389, proto = "tcp" },
      { desc = "Kerberos", from = 88, to = 88, proto = "tcp" },
      { desc = "HTTPS", from = 443, to = 443, proto = "tcp" },
      { desc = "HTTP", from = 80, to = 80, proto = "tcp" },
      { desc = "Dynamic RPC", from = 49152, to = 65535, proto = "tcp" },
      { desc = "SMB", from = 445, to = 445, proto = "tcp" },
      { desc = "LDAP TCP", from = 389, to = 389, proto = "tcp" },
      { desc = "LDAP UDP", from = 389, to = 389, proto = "udp" },
      { desc = "NetBIOS", from = 135, to = 135, proto = "tcp" },
      { desc = "High TCP Ports", from = 1024, to = 65535, proto = "tcp" },
      { desc = "DNS (UDP)", from = 53, to = 53, proto = "udp" },
      { desc = "DNS (TCP)", from = 53, to = 53, proto = "tcp" },
    ]

    content {
      description = ingress.value.desc
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.proto
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ADFS-SAML-SG"
    Environment = "prod"
  }
}



###############################
# ROUTE 53 RECORD
###############################


data "aws_route53_zone" "selected" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "example" {
  zone_id    = data.aws_route53_zone.selected.zone_id
  name       = var.record_name
  type       = var.record_type
  ttl        = 300
  records    = [aws_instance.webserver.public_ip]
  depends_on = [aws_instance.webserver]
}