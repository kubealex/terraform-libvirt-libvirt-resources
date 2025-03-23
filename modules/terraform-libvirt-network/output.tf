output "libvirt_network_name" {
  description = "The name of the network"
  value       = libvirt_network.vm_network.name
}

output "libvirt_network_cidr" {
  description = "The CIDR block of the network"
  value       = libvirt_network.vm_network.addresses
}

