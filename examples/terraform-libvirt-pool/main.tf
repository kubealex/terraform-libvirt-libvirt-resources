module "libvirt_pool" {
  source      = "github.com/kubealex/terraform-libvirt//modules/terraform-libvirt-pool"
  pool_name   = "my_pool"
  pool_path   = "/path/to/pool"
}
