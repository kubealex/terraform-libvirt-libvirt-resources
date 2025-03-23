output "libvirt_pool_name" {
  description = "The name of the pool"
  value       = libvirt_pool.vm_pool.name
}

output "libvirt_pool_path" {
  description = "The path where the pool is located"
  value       = libvirt_pool.vm_pool.path
}

