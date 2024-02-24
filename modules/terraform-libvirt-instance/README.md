# Terraform Module: terraform-libvirt-instance

## Description

This Terraform module provisions virtual instances with customizable configurations.

## Variables

| Variable Name                  | Description                                        | Required | Default Value            |
| ------------------------------ | -------------------------------------------------- | -------- | ------------------------ |
| `instance_count`               | Number of instances to create                      | ❌       | `1`                      |
| `instance_cloud_image`         | Cloud image to use for instance provisioning      | ❌       |                          |
| `instance_autostart`         | Flag to set instance autostart      | ❌       | true                         |
| `instance_iso_image`           | ISO to use for instance provisioning              | ❌       |                          |
| `instance_additional_volume_size` | Additional block device size                    | ❌       | `0`                      |
| `instance_cloudinit_path`      | Cloud-init config to use for instance provisioning | ❌       | `./cloud_init.cfg`       |
| `instance_type`                | Instance type, Windows/Linux                      | ❌       | `linux`                  |
| `instance_hostname`            | Hostname to assign the instance via cloud-init     | ❌       | `service-vm`             |
| `instance_domain`              | Hostname to assign the instance via cloud-init     | ❌       | `example.com`            |
| `instance_cpu`                 | Number of CPUs to configure for the instance      | ❌       | `2`                      |
| `instance_memory`              | Instance memory size, in GB                       | ❌       | `4`                      |
| `instance_volume_size`         | Main volume size, in GB                       | ❌       | `20`                     |
| `instance_cloud_user`          | Cloud user credentials                             | ❌       | See default in table     |
| `instance_libvirt_pool`        | The libvirt pool to attach the instance to        | ❌       | `default`                |
| `instance_uefi_enabled`        | Set this to true if OS should be installed via ISO| ❌       | `true`                   |
| `instance_network_interfaces`  | A list of network interfaces to add to the instance| ❌       | `[]` (empty list)        |

### `instance_cloud_user` Variable Details:

| Sub-Variable  | Description               | Required | Default Value |
| ------------- | ------------------------- | -------- | ------------- |
| `username`    | Username for the instance | ❌       | `sysadmin`    |
| `password`    | Password for the instance | ❌       | `redhat`      |
| `sshkey`      | SSH key for the instance  | ❌       | `""` (empty)  |

### `instance_network_interfaces` Variable Details:

| Sub-Variable                 | Description                                        | Required | Default Value |
| ---------------------------- | -------------------------------------------------- | -------- | ------------- |
| `interface_network`             | Name of the network to attach the interface to                      | ✔️       |               |
| `interface_mac_address`     | MAC address of the network interface               | ❌       |               |
| `interface_addresses`       | List of IP addresses for the network interface    | ❌       | `[]` (empty list) |
| `interface_hostname`        | Hostname for the network interface                | ❌       |               |
| `interface_wait_for_lease`  | Whether to wait for DHCP lease on the interface   | ❌       | `false`       |

## Example

```hcl
module "instance_provisioning" {
  source                    = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-instance"
  instance_count            = 2
  instance_cloud_image      = "ubuntu:latest"
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
  instance_libvirt_pool      = "ssd-pool"
  instance_uefi_enabled      = true
  instance_network_interfaces = [
    {
      interface_network_name           = "internal"
      interface_mac_address    = "52:54:00:12:34:56"
      interface_addresses      = ["192.168.1.2"]
      interface_hostname       = "eth0-host"
      interface_wait_for_lease = true
    },
    {
      interface_network_name           = "internal"
      interface_mac_address    = "52:54:00:65:78:9A"
      interface_addresses      = ["192.168.2.2"]
      interface_hostname       = "eth1-host"
      interface_wait_for_lease = false
    },
  ]
}
