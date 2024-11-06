output "wg_ip" {
  value       = aws_eip.wireguard.public_ip
}

output "wg_server_config" {
  value       = var.wg_server_config
}

