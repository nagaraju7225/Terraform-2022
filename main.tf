
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
  cidr_block = var.cidrranges[count.index]
  availability_zone = "${var.region}${count.index%2 == 0?"a":"b"}" 
  
    tags = {
      "Name" = var.subnets[count.index]
    }

  depends_on = [ 
      aws_vpc.ntiervpc
   ]

}