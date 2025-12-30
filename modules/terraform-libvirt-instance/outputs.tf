# --- Identifiers ---

output "ids" {
  description = "The unique identifiers (UUIDs) of the virtual machines."
  value       = libvirt_domain.libvirt-vm[*].id
}

output "names" {
  description = "The names assigned to the virtual machines."
  value       = libvirt_domain.libvirt-vm[*].name
}
