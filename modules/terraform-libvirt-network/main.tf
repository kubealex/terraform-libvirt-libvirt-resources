resource "libvirt_network" "vm_network" {
  autostart = var.network_autostart
  name = var.network_name
  mode = var.network_mode
  domain = var.network_domain
  addresses = var.network_cidr
  bridge = var.network_bridge
  mtu = var.network_mtu

  dns {
    enabled = var.network_dhcp_enabled
    local_only = var.network_dhcp_local

    dynamic "hosts" {
      for_each = concat(
        data.libvirt_network_dns_host_template.hosts.*.rendered
      )
      content {
        hostname = hosts.value.hostname
        ip       = hosts.value.ip
      }
    }

  }

  dnsmasq_options {
    dynamic "options" {
      for_each = concat(
        data.libvirt_network_dnsmasq_options_template.options.*.rendered,
      )
      content {
        option_name  = options.value.option_name
        option_value = options.value.option_value
      }
    }
  }


  dynamic "routes" {
      for_each = var.network_routes
      content {
        cidr  = routes.key
        gateway = routes.value
      }
  }

}

data "libvirt_network_dnsmasq_options_template" "options" {
    count = length(var.network_dnsmasq_options)
    option_name = keys(var.network_dnsmasq_options)[count.index]
    option_value = values(var.network_dnsmasq_options)[count.index]
}

data "libvirt_network_dns_host_template" "hosts" {
    count = length(var.network_dns_entries)
    hostname = keys(var.network_dns_entries)[count.index]
    ip = values(var.network_dns_entries)[count.index]
}
