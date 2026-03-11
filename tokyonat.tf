resource "aws_eip" "tokyo_nat_eip" {
    
  tags = { Name = "tokyo-nat-eip" }
}


resource "aws_nat_gateway" "tokyo_nat" {
  allocation_id = aws_eip.tokyo_nat_eip.id
  subnet_id     = aws_subnet.tokyo_public_a.id

  tags = { Name = "tokyo-nat" }
}
