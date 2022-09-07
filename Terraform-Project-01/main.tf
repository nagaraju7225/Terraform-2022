provider "aws" {
  region = "ap-south-1"
}

#--------------
# Create a VPC
#--------------

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "VENSARA VPC"
  }
}

#-----------------------------------------
# Create a public subnet on AZ ap-south-1b
#-----------------------------------------
resource "aws_subnet" "public_ap_south_1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = var.subnet1_az

  tags = {
    Name = "Public Subnet ap-south-1b"
  }
}

#-----------------------------------------
# Create a public subnet on AZ ap-south-1a
#-----------------------------------------
resource "aws_subnet" "public_ap_south_1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet2_cidr
  availability_zone = var.subnet1_az

  tags = {
    Name = "Public Subnet ap-south-1a"
  }
}

#-------------------------------
# Create an IGW for your new VPC
#-------------------------------
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "VENSARA VPC - Internet Gateway"
  }
}

#----------------------------------
# Create an RouteTable for your VPC
#----------------------------------
resource "aws_route_table" "my_vpc_public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "Public Subnets Route Table for DEMO VPC"
    }
}

#--------------------------------------------------------------
# Associate the RouteTable to the Subnet created at ap-south-1a
#--------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1a_public" {
    subnet_id = aws_subnet.public_ap_south_1a.id
    route_table_id = aws_route_table.my_vpc_public.id
}

#--------------------------------------------------------------
# Associate the RouteTable to the Subnet created at ap-south-1b
#--------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1b_public" {
    subnet_id = aws_subnet.public_ap_south_1b.id
    route_table_id = aws_route_table.my_vpc_public.id
}