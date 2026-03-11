# Explanation: Shinjuku Station is the hub—Tokyo is the data authority.
resource "aws_ec2_transit_gateway" "shinjuku_tgw01" {
  description = "shinjuku-tgw01 (Tokyo hub)"
  tags = { Name = "shinjuku-tgw01" }
}

# Explanation: Shinjuku connects to the Tokyo VPC—this is the gate to the medical records vault.
resource "aws_ec2_transit_gateway_vpc_attachment" "shinjuku_attach_tokyovpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.shinjuku_tgw01.id
  vpc_id             = aws_vpc.tokyovpc.id
  subnet_ids         = [aws_subnet.tokyo_private_a.id, aws_subnet.tokyo_private_b.id]
  tags = { Name = "shinjuku-attach-tokyovpc01" }
}

# # Explanation: Shinjuku opens a corridor request to Liberdade—compute may travel, data may not.
resource "aws_ec2_transit_gateway_peering_attachment" "shinjuku_to_liberdade_peer01" {
  transit_gateway_id      = aws_ec2_transit_gateway.shinjuku_tgw01.id
  peer_region             = "sa-east-1"
  peer_transit_gateway_id = data.terraform_remote_state.saopaulo.outputs.saopaulo_tgw_id
    peer_account_id         = data.aws_caller_identity.current.account_id



  

  tags = { Name = "shinjuku-to-liberdade-peer01" }
}

data "aws_caller_identity" "current" {}

