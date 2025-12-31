module "instance_provisioning" {
  source                       = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-instance"
# version                      = "0.1.3" # Uncomment only if you are using the version 0.8.x of the provider

  instance_count               = 2
  instance_cloud_image         = "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
  instance_type                = "linux"
  instance_hostname            = "web-server"
  instance_domain              = "example.com"
  instance_cpu                 = 2
  instance_memory              = 4
  instance_volume_size         = 50

  instance_cloud_user = {
    username                   = "admin"
    password                   = "securepass"
    sshkey                     = "ssh-rsa AAAAB3NzaC1yc2EAAA...your-ssh-key-here"
  }

  instance_libvirt_pool        = "default"
  instance_uefi_enabled        = true
  instance_firmware            = "/usr/share/edk2/ovmf/OVMF_CODE.fd"

  instance_network_interfaces = [
    {
      interface_network_name    = "default"
      interface_mac_address     = "52:54:00:12:34:56"
      interface_address         = "192.168.1.2"
      interface_prefix          = 24
      interface_hostname        = "eth0-host"
      interface_wait_for_lease  = true
    },
    {
      interface_network_name    = "default"
      interface_mac_address     = "52:54:00:65:78:9A"
      interface_address         = "192.168.2.2"
      interface_prefix          = 16
      interface_hostname        = "eth1-host"
      interface_wait_for_lease  = false
    },
  ]
}
