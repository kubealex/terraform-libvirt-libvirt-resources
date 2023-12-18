variable "network_autostart" {
  description = "Whether to autostart the libvirt network"
  type        = bool
  default     = true
}

variable "network_name" {
  description = "Name of the libvirt network"
  type        = string
}

variable "network_mode" {
  description = "Mode of the libvirt network"
  type        = string
  default     = "nat"
}

variable "network_domain" {
  description = "Domain of the libvirt network"
  type        = string
  default     = null
}

variable "network_cidr" {
  description = "CIDR for the libvirt network"
  type        = list(string)
  default = [ "192.168.122.0/24" ]
}

variable "network_bridge" {
  description = "Bridge for the libvirt network"
  type        = string
  default = null
}

variable "network_mtu" {
  description = "MTU for the libvirt network"
  type        = number
  default = null
}

variable "network_dhcp_enabled" {
  description = "Whether DHCP is enabled for the libvirt network"
  type        = bool
  default     = false
}

variable "network_dhcp_local" {
  description = "Whether DHCP is local-only for the libvirt network"
  type        = bool
  default     = false
}

variable "network_dnsmasq_options" {
  description = "Map of dnsmasq options for the libvirt network"
  type        = map(string)
  default = {}
}

variable "network_dns_entries" {
  description = "Map of DNS entries for the libvirt network"
  type        = map(string)
  default = {}
}

variable "network_routes" {
  description = "Map of routes for the libvirt network (format CIDR = gateway --> '10.0.0.1/24' = '10.0.0.1' )"
  type        = map(string)
  default = {}
}

