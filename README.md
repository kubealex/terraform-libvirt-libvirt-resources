# Terraform module for libvirt resources

This set of modules has been created to streamline the creation of libvirt resources using the awesome [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt) by [dmacvicar](https://github.com/dmacvicar)!

With this module you will be able to create from scratch with a few parameters:

- [Libvirt networks](./modules/terraform-libvirt-network/)
- [Libvirt pools](./modules/terraform-libvirt-pool/)
- [Libvirt instances](./modules/terraform-libvirt-instance/)

## Usage

These are minimal examples, the full examples are available in the [examples](./examples/) directory.

`terraform-libvirt-network`:

```hcl
module "libvirt_network" {
  source                       = "github.com/kubealex/terraform-libvirt//modules/terraform-libvirt-network"
  network_autostart    = true
  network_name         = "example_network"
  network_mode         = "nat"
  network_domain       = "example.com"
  network_cidr         = ["192.168.122.0/24"]
  network_bridge       = "br0"
  network_mtu          = 1500
  network_dhcp_enabled = true
  network_dhcp_local   = false
  network_dnsmasq_options = {
    "server" = "/example.com/192.168.122.1"
  }
  network_dns_entries = {
    "example" = "192.168.122.2"
  }
  network_routes = {
    "10.0.0.0/24" = "10.0.0.1"
  }
}
```

`terraform-libvirt-pool`:

```hcl
module "libvirt_pool" {
  source      = "github.com/kubealex/terraform-libvirt//modules/terraform-libvirt-pool"
  pool_name   = "my_pool"
  pool_path   = "/path/to/pool"
}
```

`terraform-libvirt-instance`:

```hcl
module "instance_provisioning" {
  source                    = "github.com/kubealex/terraform-libvirt//modules/terraform-libvirt-instance"
  instance_count            = 2
  instance_cloud_image      = "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
  instance_type             = "linux"
  instance_hostname         = "web-server"
  instance_domain           = "example.com"
  instance_cpu              = 2
  instance_memory           = 4
  instance_volume_size      = 50
  instance_cloud_user = {
    username = "admin"
    password = "securepass"
    sshkey   = "ssh-rsa AAAAB3NzaC1yc2EAAA...your-ssh-key-here"
  }
  instance_libvirt_network   = "default"
  instance_libvirt_pool      = "default"
  instance_uefi_enabled      = true
  instance_firmware          = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
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
```

