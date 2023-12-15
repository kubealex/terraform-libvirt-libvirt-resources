# Terraform Module: Instance Provisioning

This Terraform module is designed to provision virtual instances using libvirt. It supports various configuration options to customize the instance according to your needs.

## Usage

```hcl
module "example_instance" {
  source  = "github.com/kubealex/terraform-libvirt//modules/terraform-libvirt-vm"

  instance_cloud_image   = "your-cloud-image"
  instance_iso_image     = "your-iso-image"
  instance_type          = "linux"
  instance_hostname      = "service-vm"
  instance_domain        = "example.com"
  instance_cpu           = 2
  instance_memory        = 4
  instance_volume_size   = 20

  instance_cloud_user = {
    username = "sysadmin"
    password = "redhat"
    sshkey   = ""
  }

  libvirt_network       = "default"
  libvirt_pool          = "default"
  instance_uefi_enabled = true
}
