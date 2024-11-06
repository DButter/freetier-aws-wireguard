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
    name        = string
    public_key  = string
    private_key = string
    cidr        = string
  }))
}

variable "ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to access SSH"
  type        = list(string)
  default     = []
}