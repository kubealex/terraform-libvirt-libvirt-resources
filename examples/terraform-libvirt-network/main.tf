module "libvirt_network" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-network"
  network_autostart         = true
  network_name              = "example_network"
  network_mode              = "nat"
  network_domain            = "example.com"
  network_cidr              = ["192.168.122.0/24"]
  network_bridge            = "br0"
  network_mtu               = 1500
  network_dns_enabled       = true
  network_dns_local         = false
  network_dhcp_enabled      = true
  network_dhcp_range_start  = "192.168.122.15"
  network_dhcp_range_end    = "192.168.122.50"
  network_dnsmasq_options   = {
    "server" = "/example.com/192.168.122.1"
  }
  network_dns_entries       = {
    "example" = "192.168.122.2"
  }
  network_routes            = {
    "10.0.0.0/24" = "10.0.0.1"
  }
}