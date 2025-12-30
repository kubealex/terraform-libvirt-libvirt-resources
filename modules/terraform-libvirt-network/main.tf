resource "libvirt_network" "vm_network" {
  autostart = var.network_autostart
  name      = var.network_name

  # domain is now a nested block
  domain {
    name       = var.network_domain
    local_only = var.network_dns_local ? "yes" : "no"
  }

  # forward mode configuration (was previously "mode")
  forward {
    mode = var.network_mode
  }

  # bridge is now a nested block
  bridge {
    name = var.network_bridge
  }

  # mtu is now a nested block
  mtu {
    size = var.network_mtu
  }

  # addresses is now "ips" with nested configuration
  dynamic "ips" {
    for_each = var.network_cidr
    content {
      address = split("/", ips.value)[0]
      prefix  = tonumber(split("/", ips.value)[1])

      # DHCP configuration is now nested under ips
      dynamic "dhcp" {
        for_each = var.network_dhcp_enabled ? [1] : []
        content {
          # DHCP ranges configuration
          dynamic "ranges" {
            for_each = var.network_dhcp_range_start != null && var.network_dhcp_range_end != null ? [1] : []
            content {
              start = var.network_dhcp_range_start
              end   = var.network_dhcp_range_end
            }
          }
        }
      }
    }
  }

  # DNS configuration
  dns {
    enable = var.network_dns_enabled ? "yes" : "no"

    # DNS hosts
    dynamic "host" {
      for_each = var.network_dns_entries
      content {
        ip = host.value
        hostnames {
          hostname = host.key
        }
      }
    }

    # SRV records (note: "srvs" is now "sr_vs")
    dynamic "sr_vs" {
      for_each = var.network_dns_srv_records
      content {
        service  = sr_vs.value.service
        protocol = sr_vs.value.protocol
        domain   = sr_vs.value.domain
        target   = sr_vs.value.target
        port     = sr_vs.value.port
        priority = sr_vs.value.priority
        weight   = sr_vs.value.weight
      }
    }
  }

  # Routes configuration
  dynamic "routes" {
    for_each = var.network_routes
    content {
      address = split("/", routes.key)[0]
      prefix  = tonumber(split("/", routes.key)[1])
      gateway = routes.value
    }
  }
}
