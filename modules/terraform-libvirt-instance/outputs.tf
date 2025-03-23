output "libvirt_instance" {
  value = [
    for vm in libvirt_domain.libvirt_instance : {
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
