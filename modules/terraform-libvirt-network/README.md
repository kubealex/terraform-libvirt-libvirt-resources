# Terraform Module: terraform-libvirt-network

## Description

This Terraform module sets up a libvirt network with customizable configurations.

## Variables

| Variable Name                          | Description                                        | Required | Default Value |
| --------------------------------------| -------------------------------------------------- | -------- | ------------- |
| `network_autostart`           | Whether to autostart the libvirt network           | ❌       | `true`       |
| `network_name`                      | Name of the libvirt network                        | ✔️       |               |
| `network_mode`                 | Mode of the libvirt network                        | ❌       | `nat`         |
| `network_domain`               | Domain of the libvirt network                      | ❌       |               |
| `network_cidr`                 | CIDR for the libvirt network                       | ❌       | `["192.168.122.0/24"]` |
| `network_bridge`               | Bridge for the libvirt network                     | ❌       |               |
| `network_mtu`                  | MTU for the libvirt network                        | ❌       |               |
| `network_dns_enabled`         | Whether DNS is enabled for the libvirt network    | ❌       | `false`       |
| `network_dns_local`           | Whether DNS is local-only for the libvirt network | ❌       | `false`       |
| `network_dhcp_enabled`         | Whether DHCP is enabled for the libvirt network    | ❌       | `false`       |
| `network_dhcp_range_start`           | DHCP Range start for given address | ❌       |        |
| `network_dhcp_range_end`           | DHCP Range end for given address | ❌       |        |
| `network_dnsmasq_options`      | Map of dnsmasq options for the libvirt network     | ❌       | `{}`          |
| `network_dns_entries`          | Map of DNS entries for the libvirt network         | ❌       | `{}`          |
| `network_routes`               | Map of routes for the libvirt network              | ❌       | `{}`          |

## Example invocation

```hcl
module "libvirt_network" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-network"
  network_autostart    = true
  network_name              = "example_network"
  network_mode         = "nat"
  network_domain       = "example.com"
  network_cidr         = ["192.168.122.0/24"]
  network_bridge       = "br0"
  network_mtu          = 1500
  network_dns_enabled = true
  network_dns_local   = false
  network_dhcp_enabled = true
  network_dhcp_range_start = "192.168.122.15"
  network_dhcp_range_end = "192.168.122.50"
  network_dnsmasq_options = {
    "server" = "/example.com/192.168.122.1"
  }
  network_dns_entries = {
    "example" = "192.168.122.2"
  }
  network_routes = {
    "10.0.0.0/24" = "10.0.0.1"
  }
}
