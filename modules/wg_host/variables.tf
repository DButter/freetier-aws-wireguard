variable "wg_server_config" {
  description = "WireGuard server config"
  type = object({
    wg_cidr  = string
    wg_port = number
  })
  default = {
    wg_cidr = "172.16.16.0/20",
    wg_port = 51820
  }
}

variable "wg_server_keypair" {
  description = "WireGuard server key pair"
  type = object({
    public_key  = string
    private_key = string
  })
  sensitive = true
}

variable "wg_client_config" {
  description = "List of client key pairs for WireGuard"
  type = list(object({
    name       = string
    public_key = string
    private_key = string
    cidr = string
  }))
  sensitive = true
}

variable "sg_id" {
    type = string
}

variable "random_suffix" {
    type = string
}

variable "ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to access SSH"
  type        = list(string)
  default     = []
}

variable "public_ssh_key" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    "ManagedBy" = "Terraform"
  }
}