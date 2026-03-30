# ############################################
# # Outputs for São Paulo
# ############################################
output "saopaulo_vpc_cidr" {
  value = aws_vpc.liberdade_vpc01.cidr_block
}

output "saopaulo_tgw_id" {
  value = aws_ec2_transit_gateway.liberdade_tgw01.id
}