# Instantiate VM with cloud image
resource "libvirt_volume" "os_image" {
  count    = var.instance_cloud_image != "" ? var.instance_count : 0
  name     = "${var.instance_hostname}-${count.index}-os_image"
  pool     = var.instance_libvirt_pool
  format   = "qcow2"

  create = {
    content = {
      url = var.instance_cloud_image
    }
  }
}

resource "libvirt_volume" "os_disk" {
  count    = var.instance_count
  name     = "${var.instance_hostname}-${count.index}"
  pool     = var.instance_libvirt_pool
  capacity = var.instance_volume_size * 1073741824

  dynamic "backing_store" {
    for_each = var.instance_cloud_image != "" ? [1] : []
    content {
      path = libvirt_volume.os_image[count.index].path
      format {
        type = "qcow2"
      }
    }
  }
}

# Generate CloudInit disk
resource "libvirt_cloudinit_disk" "commoninit" {
  count     = var.instance_cloud_image != "" && var.instance_type == "linux" ? var.instance_count : 0
  name      = "${var.instance_hostname}-${count.index}-commoninit"
  user_data = templatefile(var.instance_cloudinit_path, {
    instance_hostname   = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}.${var.instance_domain}" : "${var.instance_hostname}.${var.instance_domain}"
    instance_fqdn       = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}.${var.instance_domain}" : "${var.instance_hostname}.${var.instance_domain}"
    cloud_user_sshkey   = var.instance_cloud_user.sshkey != null ? var.instance_cloud_user.sshkey : ""
    cloud_user_username = var.instance_cloud_user.username
    cloud_user_password = var.instance_cloud_user.password
  })
  meta_data = yamlencode({
    instance-id    = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}" : var.instance_hostname
    local-hostname = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}" : var.instance_hostname
  })
}

# Upload CloudInit ISO to libvirt volume
resource "libvirt_volume" "cloudinit_volume" {
  count  = var.instance_cloud_image != "" && var.instance_type == "linux" ? var.instance_count : 0
  name   = "${var.instance_hostname}-${count.index}-cloudinit.iso"
  pool   = var.instance_libvirt_pool
  format = "raw"

  create = {
    content = {
      url = libvirt_cloudinit_disk.commoninit[count.index].path
    }
  }
}

resource "libvirt_volume" "storage_image" {
  count    = var.instance_additional_volume_size != 0 ? var.instance_count : 0
  name     = "${var.instance_hostname}-storage_image-${count.index}"
  pool     = var.instance_libvirt_pool
  capacity = var.instance_additional_volume_size * 1073741824

  target {
    format {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "service-vm" {
  count     = var.instance_count
  autostart = var.instance_autostart
  name      = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}" : var.instance_hostname
  memory    = var.instance_memory * 1024
  vcpu      = var.instance_cpu
  type      = "kvm"
  running   = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = var.instance_uefi_enabled ? "q35" : null
    firmware     = var.instance_uefi_enabled ? "efi" : null
    loader       = var.instance_uefi_enabled ? var.instance_firmware : null
    loader_readonly = var.instance_uefi_enabled ? true : null
    loader_type  = var.instance_uefi_enabled ? "pflash" : null
    boot_devices = ["hd", "cdrom", "network"]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = concat(
      # OS Disk
      [{
        source = {
          file = {
            file = libvirt_volume.os_disk[count.index].path
          }
        }
        target = {
          dev = var.instance_type == "windows" ? "sda" : "vda"
          bus = var.instance_type == "windows" ? "sata" : "virtio"
        }
        driver = var.instance_type == "windows" ? {
          name    = "qemu"
          type    = "qcow2"
          discard = "unmap"
        } : null
      }],
      # CloudInit ISO (if Linux)
      var.instance_cloud_image != "" && var.instance_type == "linux" ? [{
        source = {
          file = {
            file = libvirt_volume.cloudinit_volume[count.index].path
          }
        }
        target = {
          dev = "sdb"
          bus = "sata"
        }
        device = "cdrom"
      }] : [],
      # ISO Image (if provided)
      var.instance_iso_image != "" ? [{
        source = {
          file = {
            file = var.instance_iso_image
          }
        }
        target = {
          dev = var.instance_type == "linux" ? "sdb" : "sdc"
          bus = "sata"
        }
        device = "cdrom"
      }] : [],
      # Additional storage volume
      var.instance_additional_volume_size != 0 ? [{
        source = {
          file = {
            file = libvirt_volume.storage_image[count.index].path
          }
        }
        target = {
          dev = var.instance_type == "windows" ? "sdb" : "vdb"
          bus = var.instance_type == "windows" ? "sata" : "virtio"
        }
      }] : []
    )

    interfaces = [
      for idx, iface in var.instance_network_interfaces : {
        source = {
          network = {
            network = iface.interface_network
          }
        }
        model = {
          type = "virtio"
        }
        mac = iface.interface_mac_address != null ? {
          address = iface.interface_mac_address
        } : null
        # Note: hostname, addresses, and wait_for_lease are not directly supported in the new schema
        # These would need to be handled via DHCP configuration in the network or cloud-init
      }
    ]

    consoles = [{
      target = {
        type = "serial"
        port = 0
      }
      source = {
        pty = {
          path = ""
        }
      }
    }]

    graphics = [{
      vnc = {
        autoport = "yes"
        listen = {
          type    = "address"
          address = "0.0.0.0"
        }
      }
    }]

    # Add tablet input for Windows to fix mouse issues
    inputs = var.instance_type == "windows" ? [{
      type = "tablet"
      bus  = "usb"
    }] : []
  }

  # necessary when using UEFI
  lifecycle {
    ignore_changes = [
      os[0].nv_ram
    ]
  }
}
