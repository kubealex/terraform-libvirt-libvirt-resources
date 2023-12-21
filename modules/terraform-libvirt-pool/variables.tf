variable "pool_name" {
  description = "Name of the libvirt pool"
  type        = string
  default     = "default"
}

variable "pool_path" {
  description = "Path for the libvirt pool"
  type        = string
  default = "/var/lib/libvirt/images"
}
