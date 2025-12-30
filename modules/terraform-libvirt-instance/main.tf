# 1. Base OS Image Volume
resource "libvirt_volume" "os_image" {
  count  = var.instance_cloud_image != "" ? var.instance_count : 0
  name   = "${var.instance_hostname}-${count.index}-os_image"
  pool   = var.instance_libvirt_pool
  target = { format = { type = "qcow2" } }
  create = { content = { url = var.instance_cloud_image } }
}

# 2. Main Writable OS Disk
resource "libvirt_volume" "os_disk" {
  count    = var.instance_count
  name     = "${var.instance_hostname}-${count.index}"
  pool     = var.instance_libvirt_pool
  capacity = var.instance_volume_size * 1073741824
  target   = { format = { type = "qcow2" } }
  backing_store = var.instance_cloud_image != "" ? {
    path   = libvirt_volume.os_image[count.index].path
    format = { type = "qcow2" }
  } : null
}

# 3. Cloud-Init ISO Generation
resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.instance_cloud_image != "" && var.instance_type == "linux" ? var.instance_count : 0
  name  = "${var.instance_hostname}-${count.index}-commoninit"
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

# 4. Cloud-Init Volume (Set format to 'iso' to match Libvirt detection)
resource "libvirt_volume" "cloudinit_volume" {
  count  = var.instance_cloud_image != "" && var.instance_type == "linux" ? var.instance_count : 0
  name   = "${var.instance_hostname}-${count.index}-cloudinit.iso"
  pool   = var.instance_libvirt_pool
  target = { format = { type = "iso" } }
  create = { content = { url = libvirt_cloudinit_disk.commoninit[count.index].path } }
}

# 5. Additional Storage Volume
resource "libvirt_volume" "storage_image" {
  count    = var.instance_additional_volume_size != 0 ? var.instance_count : 0
  name     = "${var.instance_hostname}-storage_image-${count.index}"
  pool     = var.instance_libvirt_pool
  capacity = var.instance_additional_volume_size * 1073741824
  target   = { format = { type = "qcow2" } }
}

# 6. Virtual Machine Definition
resource "libvirt_domain" "libvirt-vm" {
  count     = var.instance_count
  name      = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}" : var.instance_hostname
  vcpu      = var.instance_cpu
  memory    = var.instance_memory * 1024
  memory_unit   = "MiB"
  autostart = var.instance_autostart
  type      = "kvm"
  running   = true

  features = var.instance_uefi_enabled ? { acpi = true } : null

  os = {
    type            = "hvm"
    type_arch       = "x86_64"
    type_machine    = var.instance_uefi_enabled ? "q35" : null
    firmware        = var.instance_uefi_enabled ? "efi" : null
    loader          = var.instance_uefi_enabled ? var.instance_firmware : null
    loader_readonly = var.instance_uefi_enabled ? "yes" : null
    loader_type     = var.instance_uefi_enabled ? "pflash" : null
    boot_devices    = [{ dev = "hd" }, { dev = "cdrom" }, { dev = "network" }]
  }

  cpu = { mode = "host-passthrough" }

  devices = {
    disks = [
      for disk in [
        # 0 — OS disk (always present)
        {
          source = {
            volume = {
              pool   = libvirt_volume.os_disk[count.index].pool
              volume = libvirt_volume.os_disk[count.index].name
            }
          }
          target = {
            dev = var.instance_type == "windows" ? "sda" : "vda"
            bus = var.instance_type == "windows" ? "sata" : "virtio"
          }
          driver = {
            type = "qcow2"
          }
        },

        # 1 — Additional storage (optional)
        var.instance_additional_volume_size != 0 ? {
          source = {
            volume = {
              pool   = libvirt_volume.storage_image[count.index].pool
              volume = libvirt_volume.storage_image[count.index].name
            }
          }
          target = {
            dev = var.instance_type == "windows" ? "sdb" : "vdb"
            bus = var.instance_type == "windows" ? "sata" : "virtio"
          }
          driver = {
            type = "qcow2"
          }
        } : null,

        # 2 — Cloud-init disk (optional)
        var.instance_cloud_image != "" && var.instance_type == "linux" ? {
          device = "cdrom"
          source = {
            volume = {
              pool   = libvirt_volume.cloudinit_volume[count.index].pool
              volume = libvirt_volume.cloudinit_volume[count.index].name
            }
          }
          target = {
            dev = "sda"
            bus = "sata"
          }
        } : null
      ] : disk if disk != null
    ]

    interfaces = [for iface in var.instance_network_interfaces : {
      source = { network = { network = iface.interface_network } }
      model  = { type = "virtio" }
      mac    = iface.interface_mac_address != null ? { address = iface.interface_mac_address } : null
    }]

    graphics = [
      {
        type = "vnc"
        vnc = {
          autoport = true
          listen   = "127.0.0.1"
        }
      }
    ]

    inputs = var.instance_type == "windows" ? [{ type = "tablet", bus = "usb" }] : null
  }

  lifecycle {
    ignore_changes = [
      os.nv_ram
    ]
  }
}
