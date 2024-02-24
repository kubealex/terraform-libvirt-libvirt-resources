# Terraform Module: terraform-libvirt-pool

## Description

This Terraform module creates a libvirt pool with customizable configurations.

## Variables

| Variable Name  | Description                        | Required | Default Value              |
| -------------- | ---------------------------------- | -------- | -------------------------- |
| `pool_name`    | Name of the libvirt pool            | ❌       |                            |
| `pool_path`    | Path for the libvirt pool           | ❌       | `/var/lib/libvirt/images`  |

ℹ️ Icons: ✔️ - Required, ❌ - Optional

## Example

```hcl
module "libvirt_pool" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-pool"
  pool_name   = "my_pool"
  pool_path   = "/path/to/pool"
}
