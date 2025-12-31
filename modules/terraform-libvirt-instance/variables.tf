variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of instances to create"
}

variable "instance_autostart" {
  type        = bool
  description = "Flag to configure autostart for the instance"
  default     = true
}

variable "instance_cloud_image" {
  type        = string
  description = "Cloud image URL to use for instance provisioning (HTTP/HTTPS URL supported)"
  default     = ""
}

variable "instance_iso_image" {
  type        = string
  description = "ISO file path to use for instance provisioning"
  default     = ""
}

variable "instance_additional_volume_size" {
  type        = number
  description = "Additional block device size in GB"
  default     = 0
}

variable "instance_cloudinit_path" {
  type        = string
  description = "Path to cloud-init config template to use for instance provisioning"
  default     = "./cloud_init.cfg"
}

variable "instance_type" {
  type        = string
  description = "Instance type: 'windows' or 'linux' (affects disk bus type)"
  default     = "linux"
  validation {
    condition     = contains(["windows", "linux"], var.instance_type)
    error_message = "Instance type must be either 'windows' or 'linux'."
  }
}

variable "instance_hostname" {
  type        = string
  default     = "libvirt-vm"
  description = "Hostname to assign the instance via cloud-init"
}

variable "instance_domain" {
  type        = string
  default     = "example.com"
  description = "Domain name to append to hostname"
}

variable "instance_cpu" {
  type        = number
  default     = 2
  description = "Number of vCPUs to configure for the instance"
}

variable "instance_memory" {
  type        = number
  default     = 4
  description = "Instance memory size in GB"
}

variable "instance_volume_size" {
  type        = number
  default     = 20
  description = "Instance OS volume size in GB"
}

variable "instance_cloud_user" {
  type = object({
    username = string
    password = string
    sshkey   = optional(string)
  })

  default = {
    username = "sysadmin"
    password = "redhat"
    sshkey   = ""
  }
  description = "Cloud-init user configuration"
}

variable "instance_libvirt_pool" {
  type        = string
  description = "The libvirt pool to attach the instance volumes to"
  default     = "default"
}

variable "instance_uefi_enabled" {
  type        = bool
  default     = true
  description = "Enable UEFI firmware for the instance"
}

variable "instance_firmware" {
  type        = string
  default     = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
  description = "Path to the OVMF firmware on the host machine. Ubuntu=/usr/share/OVMF/OVMF_CODE.fd"
}

variable "instance_network_interfaces" {
  type = list(object({
    interface_network     = string
    interface_mac_address = optional(string)
    interface_address     = optional(string)
    interface_prefix      = optional(number, 24)
  }))
  default = [{
    interface_network = "default"
  }]
  description = "A list of network interfaces to add to the instance. Uses DHCP by default, or specify interface_address for static IP assignment. interface_prefix defaults to 24."
}
