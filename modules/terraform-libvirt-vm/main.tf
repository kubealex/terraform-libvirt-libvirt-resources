# Instantiate VM with cloud image
resource "libvirt_volume" "os_image" {
  count = var.instance_cloud_image != "" ? var.instance_count : 0
  name = "${var.instance_hostname}-os_image"
  pool = var.libvirt_pool
  source = var.instance_cloud_image
  format = "qcow2"
}

resource "libvirt_volume" "os_disk" {
  count = var.instance_count
  name = var.instance_hostname
  base_volume_id = var.instance_cloud_image != "" ? element(libvirt_volume.os_image.*.id, count.index) : ""
  pool = var.libvirt_pool
  size = var.instance_volume_size*1073741824
}

# Use CloudInit ISO to add customizations to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.instance_cloud_image != "" && var.instance_type == "linux" ? var.instance_count : 0
  name = "${var.instance_hostname}-commoninit.iso"
  pool = var.libvirt_pool
  user_data = data.template_file.user_data.rendered
  #meta_data = data.template_file.meta_data.rendered
}


data "template_file" "user_data" {
  count = var.instance_count
  template = file(var.instance_cloudinit_path)
  vars = {
    instance_hostname = "${var.instance_hostname}-${count.index}.${var.instance_domain}"
    instance_fqdn = "${var.instance_hostname}-${count.index}.${var.instance_domain}"
    cloud_user_sshkey = var.instance_cloud_user.sshkey != null ? var.instance_cloud_user.sshkey : ""
    cloud_user_username = var.instance_cloud_user.username
    cloud_user_password = var.instance_cloud_user.password
  }
}

# Create the machine
resource "libvirt_domain" "service-vm" {
  count = var.instance_count
  name = ${var.instance_hostname}-${count.index}
  memory = var.instance_memory*1024
  vcpu = var.instance_cpu
  machine = var.instance_uefi_enabled ? "q35" : "pc-i440fx-rhel7.6.0"
  firmware = var.instance_uefi_enabled ? "/usr/share/edk2/ovmf/OVMF_CODE.fd" : ""

  boot_device {
    dev = [ "hd", "cdrom" ]
  }

  cpu {
    mode = "host-passthrough"
  }

  disk {
     volume_id = element(libvirt_volume.os_disk.*.id, count.index)
  }

  dynamic disk {
    for_each = var.instance_iso_image != "" && var.instance_type == "linux" ? { iso = true } : {}
    content {
      file = var.instance_iso_image
    }
  }

  network_interface {
       network_name = var.libvirt_network
       wait_for_lease = true
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

  xml {
    xslt = var.instance_type == "windows" ? file("windows-patch.xsl") : file("linux-patch.xsl")
  }

}

terraform {
 required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

