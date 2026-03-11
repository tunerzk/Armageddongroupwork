 ############################################
# # Outputs for Tokyo
# ############################################
output "tokyo_vpc_cidr" {
  value = aws_vpc.tokyovpc.cidr_block
}

output "tokyo_tgw_id" {
  value = aws_ec2_transit_gateway.shinjuku_tgw01.id
}

output "tokyo_rds_endpoint" {
  value = aws_db_instance.tokyo_rds.address
}

output "tokyo_to_sp_peering_id" {
  value = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
}

output "tokyo_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.shinjuku_attach_tokyovpc01.id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.global_app.arn
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.global_app.id
}

