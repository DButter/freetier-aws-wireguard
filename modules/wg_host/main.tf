locals {
  userdata = templatefile("${path.module}/templates/init.sh.tpl", {
    wg_cidr    = var.wg_server_config.wg_cidr
    wg_port    = var.wg_server_config.wg_port
    wg_private_key = var.wg_server_keypair.private_key
    public_ssh_key = var.public_ssh_key
    wg_peers = join("\n", [
      for p in var.wg_client_config :
      templatefile("${path.module}/templates/wg-peer.tpl", {
        peer_name   = p.name
        peer_pubkey = p.public_key
        peer_addr   = p.cidr
      })
    ])
  })
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-oracular-24.10-amd64-server-*"]
  }
}


resource "aws_security_group_rule" "allow_wg_in" {
  type              = "egress"
  from_port         = var.wg_server_config.wg_port
  to_port           = var.wg_server_config.wg_port
  protocol    = "udp"
  security_group_id = var.sg_id
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow WireGuard Traffic"
}

resource "aws_security_group_rule" "allow_ssh_in" {
  count             = length(var.ssh_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = var.sg_id
  cidr_blocks       = var.ssh_cidr_blocks
  description       = "Allow SSH Traffic"
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = var.sg_id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "wireguard" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  user_data                   = local.userdata
  user_data_replace_on_change = true
  tags = merge(var.tags, {
    Name = "wg-instance-${var.random_suffix}"
  })
}

resource "aws_eip" "wireguard" {
  domain = "vpc"
  instance = aws_instance.wireguard.id

  tags = merge(var.tags, {
    Name = "wg-eip-${var.random_suffix}"
  })
}
 
