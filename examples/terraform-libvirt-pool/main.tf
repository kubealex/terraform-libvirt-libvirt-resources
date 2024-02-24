module "libvirt_pool" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-pool"
  pool_name   = "my_pool"
  pool_path   = "/path/to/pool"
}
