module "libvirt_pool" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-pool"
  version = "0.0.1"
  pool_name   = "my_pool"
  pool_path   = "/path/to/pool"
}
