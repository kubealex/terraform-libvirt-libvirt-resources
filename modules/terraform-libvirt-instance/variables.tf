variable "instance_count" {
  type = number
  default = 1
  description = "Number of instances to create"
}

variable "instance_autostart" {
  type = bool
  description = "Flag to configure autostart for the instance"
  default = true
}

variable "instance_cloud_image" {
  type = string
  description = "Cloud image to use for instance provisioning"
  default = ""
}

variable "instance_iso_image" {
  type = string
  description = "ISO to use for instance provisioning"
  default = ""
}

variable "instance_additional_volume_size" {
  type = number
  description = "Additional block device size"
  default = 0
}

variable "instance_cloudinit_path" {
  type = string
  description = "cloud-init config to use for instance provisioning"
  default = "./cloud_init.cfg"
}

variable "instance_type" {
  type = string
  description = "Instance type, Windows/Linux"
  default = "linux"
}

variable "instance_hostname" {
  type = string
  default = "service-vm"
  description = "Hostname to assign the istance via cloud-init"
}

variable "instance_domain" {
  type = string
  default = "example.com"
  description = "Hostname to assign the istance via cloud-init"
}

variable "instance_cpu" {
  type = number
  default = 2
  description = "Number of CPUs to configure for the instance"
}

variable "instance_memory" {
  type = number
  default = 4
  description = "Instance memory size, in GB"
}

variable "instance_volume_size" {
  type = number
  default = 20
  description = "Instance memory size, in GB"
}

variable "instance_cloud_user" {
  type = object({
    username = string
    password = string
    sshkey = optional(string)
  })

  default = {
    username = "sysadmin"
    password = "redhat"
    sshkey = ""
  }
}

variable "instance_libvirt_pool" {
  type = string
  description = "The libvirt pool to attach the instance to"
  default = "default"
}

variable "instance_uefi_enabled" {
  type = bool
  default = true
  description = "Set this to true if OS should be installed via ISO"
}


variable "instance_firmware" {
  type = string
  default = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
  description = "Path to the ovmf firmware on the host machine. Ubuntu=/usr/share/OVMF/OVMF_CODE.fd"
}

variable "instance_network_interfaces" {
  type = list(object({
    interface_network = string
    interface_mac_address = optional(string)
    interface_addresses = optional(list(string), [])
    interface_hostname = optional(string)
    interface_wait_for_lease = optional(bool, true)
  })
  )
  default = [{
    interface_network = "default"
    }
  ]
  description = "A list of network interfaces to add to the instance"
}