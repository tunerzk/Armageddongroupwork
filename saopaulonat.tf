resource "aws_eip" "saopaulo_nat_eip" {
  
  domain   = "vpc"
  
  tags   = { Name = "saopaulo-nat-eip" }    
}

resource "aws_nat_gateway" "saopaulo_nat_gw" {
  
  allocation_id = aws_eip.saopaulo_nat_eip.id
  subnet_id     = aws_subnet.liberdade_public_subnet01.id

  depends_on = [aws_internet_gateway.liberdade_igw01]
}
