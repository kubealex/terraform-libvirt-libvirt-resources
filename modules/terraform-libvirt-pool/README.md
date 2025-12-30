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
  source     = "github.com/kubealex/terraform-libvirt//modules/terraform-libvirt-pool"
  version    = "0.1.3" # If you are using the version 0.8.x of the provider
  version    = "0.2"   # If you are using the version 0.9.x of the provider
  pool_name  = "my_pool"
  pool_path  = "/path/to/pool"
}
```