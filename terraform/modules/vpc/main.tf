resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_name}"
  }
}

resource "aws_subnet" "pub-subnet1" {
  vpc_id                  = aws_vpc.main-vpc.id
  count                   = length(var.pub_subnet)
  cidr_block              = var.pub_subnet[count.index]["cidr_block"]
  availability_zone       = var.pub_subnet[count.index]["availability_zone"]
  map_public_ip_on_launch = true

  tags = {
    Name = var.pub_subnet[count.index]["name"]
  }
}


resource "aws_subnet" "pri-subnet1" {
  vpc_id     = aws_vpc.main-vpc.id
  count      = length(var.pri_subnet)
  cidr_block = var.pri_subnet[count.index]["cidr_block"]

  availability_zone       = var.pri_subnet[count.index]["availability_zone"]
  map_public_ip_on_launch = false

  tags = {
    Name = var.pri_subnet[count.index]["name"]
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.resource_name}-igw"
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"

  tags = {
    Name = "${var.resource_name}nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id     = aws_eip.nat-eip.id
  subnet_id         = aws_subnet.pub-subnet1[0].id
  connectivity_type = "public"
  tags = {
    Name = "${var.resource_name}nat-gateway"
  }
}

resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.resource_name}-pub-route-table"
  }
}

resource "aws_route_table" "pri-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.resource_name}-pri-route-table"
  }
}

resource "aws_route_table_association" "pub-sn1-rt-assoc" {
  count          = length(var.pub_subnet)
  subnet_id      = aws_subnet.pub-subnet1[count.index].id
  route_table_id = aws_route_table.pub-route-table.id
}

resource "aws_route_table_association" "pub-sn2-rt-assoc" {
  count          = length(var.pri_subnet)
  subnet_id      = aws_subnet.pri-subnet1[count.index].id
  route_table_id = aws_route_table.pri-route-table.id
}



resource "aws_vpc_dhcp_options" "custom" {
  domain_name         = var.dhcp_domain_name
  domain_name_servers = var.domain_name_servers
  tags = {
    Name        = "custom-dhcp-adfs-prod"
    Environment = "prod"
  }
}

resource "aws_vpc_dhcp_options_association" "custom" {
  vpc_id          = aws_vpc.main-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.custom.id
  depends_on      = [aws_vpc.main-vpc]
}



resource "aws_s3_bucket" "adfs_cert_bucket" {
  bucket = "certificate-for-adfs-ec2instance"

  tags = {
    Name        = "ADFS Certificate Bucket"
    Environment = "Production"
  }
}
# Upload an object (local file)
resource "aws_s3_object" "uploaded_file" {
  bucket = aws_s3_bucket.adfs_cert_bucket.id
  key    = "adfs.groveops.net.pfx"                # S3 object key
  source = "${path.module}/adfs.groveops.net.pfx" # Path to local file
  # etag   = filemd5("${path.module}/example.txt") # Helps detect changes
  # content_type = "text/plain"
}