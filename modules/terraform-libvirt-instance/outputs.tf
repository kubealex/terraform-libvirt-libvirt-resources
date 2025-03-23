output "instance_networks" {
  value = [
    for vm in libvirt_domain.service-vm : {
      name        = vm.name
      network_interfaces = [
        for ni in vm.network_interface : {
          hostname    = ni.hostname
          addresses   = flatten(ni.addresses)
          network_name = ni.network_name
        }
      ]
    }
  ]
}
