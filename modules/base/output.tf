output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "ID of the created VPC"
  value       = var.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.public_subnet.*.id
}

output "wg_security_group_id" {
  value = aws_security_group.wg.id
}

output "aws_key_pair" {
  value = aws_key_pair.deployer
}

output "tls_private_key" {
  value = tls_private_key.deployer
}