resource "random_id" "tag_suffix" {
  byte_length = 4
}

locals {
  tags = {
    "ManagedBy"   = "David"
    "Environment" = "Dev"
  }
}

module "base" {
  source        = "./modules/base"
  random_suffix = random_id.tag_suffix.hex
  tags          = local.tags
}

module "wg" {
  source            = "./modules/wg_host"
  vpc_id = module.base.vpc_id
  random_suffix     = random_id.tag_suffix.hex
  wg_server_keypair = var.wg_server_keypair
  wg_client_config  = var.wg_client_config
  sg_id             = module.base.wg_security_group_id
  subnet_id = module.base.public_subnet_ids[0]
  ssh_cidr_blocks   = var.ssh_cidr_blocks
  public_ssh_key    = replace(data.local_file.public_key.content, "\n", "")
  tags              = local.tags
}

data "local_file" "public_key" {
  filename = "./id_ed25519.pub"
}