module "libvirt_pool" {
  source     = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-pool"
# version    = "0.1.3" # Uncomment only if you are using the version 0.8.x of the provider
  pool_name  = "my_pool"
  pool_path  = "/path/to/pool"
}