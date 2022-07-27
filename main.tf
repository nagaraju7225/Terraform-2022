
# we need to create a vpc resource
resource "aws_vpc" "ntiervpc" {
    cidr_block = var.vpccidr
    enable_dns_support = true
    enable_dns_hostnames = true
}
# Lets create all subnets
resource "aws_subnet" "subnets" {
  count = 6
  vpc_id = aws_vpc.ntiervpc.id
  cidr_block = cidrsubnet(var.vpccidr,8,count.index)
  availability_zone = "${var.region}${count.index%2 == 0?"a":"b"}" 
  
    tags = {
      "Name" = local.subnets[count.index]
    }

  depends_on = [ 
      aws_vpc.ntiervpc
   ]

}
#create a internet gate way
resource "aws_internet_gateway" "ntiergw" {
  vpc_id = aws_vpc.ntiervpc.id
  tags = {
    "Name" = local.igw_name
  }
  depends_on = [
    aws_vpc.ntiervpc
  ]
}
#create a route table 
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.ntiervpc.id

  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.ntiergw.id
  }

  depends_on = [
    aws_vpc.ntiervpc,
    aws_subnet.subnets[0],
    aws_subnet.subnets[1]
  ]

  tags = {
    "Name" = "publicrt"
  }
}

resource "aws_route_table_association" "webassociations" {
  count = 2
  route_table_id = aws_route_table.publicrt.id
  subnet_id = aws_subnet.subnets[count.index].id

  depends_on = [
    aws_route_table.publicrt
  ]
}
resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.ntiervpc.id

  tags = {
    "Name" = "privatert"
  }

  depends_on = [
    aws_vpc.ntiervpc,
    aws_subnet.subnets[2],
    aws_subnet.subnets[3],
    aws_subnet.subnets[4],
    aws_subnet.subnets[5],
  ]
}

resource "aws_route_table_association" "applassociation" {
  count = 4
  route_table_id = aws_route_table.privatert.id
  subnet_id = aws_subnet.subnets[count.index + 2].id
  depends_on = [
    aws_route_table.privatert
  ]
}
#create a web security group 
resource "aws_security_group" "websg" {
  name = "websg"
  description = "open 22 and 80 port for all"
  vpc_id = aws_vpc.ntiervpc.id
  
  ingress {
    cidr_blocks = [local.anywhere]
    description = "open ssh port"
    from_port = local.ssh
    protocol = local.tcp
    to_port = local.ssh
  }

  ingress {
    cidr_blocks = [local.anywhere]
    description = "open http port"
    from_port = local.http
    protocol = local.tcp
    to_port = local.http
  }

  tags = {
    "Name" = "websg"
  }
  
  depends_on = [
    aws_route_table.privatert,
    aws_route_table.publicrt
  ]
}
resource "aws_security_group" "appsg" {
  name = "appsg"
  description = "open port 8080 and 22 within vpc"
  vpc_id = aws_vpc.ntiervpc.id

  ingress {
    cidr_blocks = [ var.vpccidr ]
    description = "open ssh port"
    from_port = local.ssh
    protocol = local.tcp
    to_port = local.ssh
  }

  ingress {
    cidr_blocks = [ var.vpccidr ]
    description = "open app port"
    from_port = local.appport
    protocol = local.tcp
    to_port = local.appport
  }

  tags = {
    "Name" = "appsg"
  }
  depends_on = [
    aws_route_table.privatert,
    aws_route_table.publicrt
  ]
}
resource "aws_security_group" "dbsg" {
  name = "dbsg"
  description = "open port 3306 with in vpc"
  vpc_id = aws_vpc.ntiervpc.id

  ingress {
    cidr_blocks = [ var.vpccidr ]
    description = "open db port"
    from_port = local.dpport
    protocol = local.tcp
    to_port = local.dpport
  }

  tags = {
    "Name" = "dbsg"
  }

  depends_on = [
    aws_route_table.privatert,
    aws_route_table.publicrt
  ]
}