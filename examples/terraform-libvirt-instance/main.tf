module "instance_provisioning" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-instance"
  instance_count            = 2
  instance_autostart        = true
  instance_cloud_image      = "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
  instance_type             = "linux"
  instance_hostname         = "web-server"
  instance_domain           = "example.com"
  instance_cpu              = 4
  instance_memory           = 8
  instance_volume_size      = 50
  instance_cloud_user = {
    username = "admin"
    password = "securepass"
    sshkey   = "ssh-rsa AAAAB3NzaC1yc2EAAA...your-ssh-key-here"
  }
  instance_libvirt_network   = "default"
  instance_libvirt_pool      = "default"
  instance_uefi_enabled      = true
  instance_network_interfaces = [
    {
      interface_network_name           = "default"
      interface_mac_address    = "52:54:00:12:34:56"
      interface_addresses      = ["192.168.1.2"]
      interface_hostname       = "eth0-host"
      interface_wait_for_lease = true
    },
    {
      interface_network_name           = "default"
      interface_mac_address    = "52:54:00:65:78:9A"
      interface_addresses      = ["192.168.2.2"]
      interface_hostname       = "eth1-host"
      interface_wait_for_lease = false
    },
  ]
}
