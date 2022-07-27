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
#create app security group
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

#create a db security group
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