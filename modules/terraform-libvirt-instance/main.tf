# Instantiate VM with cloud image
resource "libvirt_volume" "os_image" {
  count = var.instance_cloud_image != "" ? var.instance_count : 0
  name = "${var.instance_hostname}-${count.index}-os_image"
  pool = var.instance_libvirt_pool
  source = var.instance_cloud_image
  format = "qcow2"
}

resource "libvirt_volume" "os_disk" {
  count = var.instance_count
  name = "${var.instance_hostname}-${count.index}"
  base_volume_id = var.instance_cloud_image != "" ? element(libvirt_volume.os_image.*.id, count.index) : ""
  pool = var.instance_libvirt_pool
  size = var.instance_volume_size*1073741824
}

# Use CloudInit ISO to add customizations to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.instance_cloud_image != "" && var.instance_type == "linux" ? var.instance_count : 0
  name = "${var.instance_hostname}-${count.index}-commoninit.iso"
  pool = var.instance_libvirt_pool
  user_data = element(data.template_file.user_data.*.rendered, count.index)
  #meta_data = data.template_file.meta_data.rendered
}

resource "libvirt_volume" "storage_image" {
  count = var.instance_additional_volume_size != 0 ? var.instance_count : 0
  name = "${var.instance_hostname}-storage_image-${count.index}"
  pool = var.instance_libvirt_pool
  size = var.instance_additional_volume_size*1073741824
  format = "qcow2"
}

data "template_file" "user_data" {
  count = var.instance_count
  template = file(var.instance_cloudinit_path)
  vars = {
    instance_hostname = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}.${var.instance_domain}" : "${var.instance_hostname}.${var.instance_domain}"
    instance_fqdn = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}.${var.instance_domain}" : "${var.instance_hostname}.${var.instance_domain}"
    cloud_user_sshkey = var.instance_cloud_user.sshkey != null ? var.instance_cloud_user.sshkey : ""
    cloud_user_username = var.instance_cloud_user.username
    cloud_user_password = var.instance_cloud_user.password
  }
}

resource "libvirt_domain" "service-vm" {
  count = var.instance_count
  autostart = var.instance_autostart
  name = var.instance_count > 1 ? "${var.instance_hostname}-${count.index}" : var.instance_hostname
  memory = var.instance_memory*1024
  vcpu = var.instance_cpu
  machine = var.instance_uefi_enabled ? "q35" : ""
  firmware = var.instance_uefi_enabled ? var.instance_firmware : ""

  boot_device {
    dev = [ "hd", "cdrom", "network" ]
  }

  cpu {
    mode = "host-passthrough"
  }

  disk {
     volume_id = element(libvirt_volume.os_disk.*.id, count.index)
  }

  dynamic disk {
    for_each = var.instance_iso_image != "" ? { iso = true } : {}
    content {
      file = var.instance_iso_image
    }
  }

  dynamic "disk" {
     for_each = var.instance_additional_volume_size != 0 ? { storage = true } : {}
     content {
     volume_id = libvirt_volume.storage_image[count.index].id
     }
   }

  dynamic "network_interface" {
    for_each = var.instance_network_interfaces
     content {
       network_name = network_interface.value.interface_network
       hostname = network_interface.value.interface_hostname
       addresses = network_interface.value.interface_addresses
       mac = network_interface.value.interface_mac_address
       wait_for_lease = network_interface.value.interface_wait_for_lease
     }
  }

  cloudinit = var.instance_cloud_image != "" && var.instance_type == "linux" ? element(libvirt_cloudinit_disk.commoninit.*.id, count.index) : null

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = "true"
  }

  # necessary when using UEFI
  lifecycle {
    ignore_changes = [
      nvram
    ]
  }

  xml {
    xslt = var.instance_type == "windows" ? file("${path.module}/windows-patch.xsl") : file("${path.module}/linux-patch.xsl")
  }

}

