resource "libvirt_network" "vm_network" {
  autostart = var.network_autostart
  name      = var.network_name

  // Waiting on support from upstream
  # dnsmasq_options = var.network_dnsmasq_options

  domain = {
    name       = var.network_domain
    local_only = var.network_dns_local ? "yes" : "no"
  }

  forward = {
    mode = var.network_mode
  }

  bridge = {
    name = var.network_bridge
  }

  mtu = {
    size = var.network_mtu
  }

  ips = [
    for cidr in var.network_cidr : {
      address = split("/", cidr)[0]
      prefix  = tonumber(split("/", cidr)[1])
      dhcp = var.network_dhcp_enabled ? {
        ranges = (var.network_dhcp_range_start != null && var.network_dhcp_range_end != null) ? [
          {
            start = var.network_dhcp_range_start
            end   = var.network_dhcp_range_end
          }
        ] : null
      } : null
    }
  ]

  dns = {
    enable = var.network_dns_enabled ? "yes" : "no"

    # Host entries (Attributes List)
    host = [
      for hostname, ip in var.network_dns_entries : {
        ip = ip
        hostnames = [
          { hostname = hostname }
        ]
      }
    ]

    sr_vs = [
      for record in var.network_dns_srv_records : {
        service  = record.service
        protocol = record.protocol
        domain   = record.domain
        target   = record.target
        port     = record.port
        priority = record.priority
        weight   = record.weight
      }
    ]

    forward_plain_names = null
    forwarders          = null
    tx_ts               = null
  }

  routes = length(var.network_routes) > 0 ? [
      for cidr, gateway in var.network_routes : {
        address = split("/", cidr)[0]
        prefix  = tonumber(split("/", cidr)[1])
        gateway = gateway
        family  = null
        metric  = null
        netmask = null
      }
    ] : null

}
