locals {
  # https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#AmazonDNS
  client_dns = ["169.254.169.253", "1.1.1.1", "1.0.0.1"]
  client_routes = [
    module.base.vpc_cidr_block, # All IPs in the VPC
    "169.254.169.253/32",        # AWS DNS
    "0.0.0.0/0",                # Route all traffic through VPN 
  ]
}
 
resource "local_file" "peerconf" {
  for_each = { for index, p in var.wg_client_config : p.name => p }
  filename = "generated/${each.value.name}.conf"
  content = templatefile("templates/client-conf.tpl", {
    server_addr    = "${module.wg.wg_ip}:${module.wg.wg_server_config.wg_port}",
    server_pubkey  = var.wg_server_keypair.public_key,
    client_addr    = each.value.cidr,
    client_privkey = each.value.private_key,
    client_dns     = join(",", local.client_dns),
    client_routes  = join(",", local.client_routes),
  })
}