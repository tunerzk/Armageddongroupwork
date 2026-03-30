# # Explanation: Liberdade knows the way to Shinjuku—Tokyo CIDR routes go through the TGW corridor.
resource "aws_route" "liberdade_to_tokyo_route01" {
  
  route_table_id         = aws_route_table.liberdade_private_rt01.id
  destination_cidr_block = "10.108.0.0/16" # Tokyo VPC CIDR (students supply)
  transit_gateway_id     = aws_ec2_transit_gateway.liberdade_tgw01.id
}

resource "aws_route" "saopaulo_private_default_route" {
  
  route_table_id         = aws_route_table.liberdade_private_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.saopaulo_nat_gw.id
}


resource "aws_route_table" "liberdade_public_rt" {
  vpc_id = aws_vpc.liberdade_vpc01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.liberdade_igw01.id
  }

  tags = {
    Name = "liberdade-public-rt"
  }
}
