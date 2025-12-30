resource "libvirt_pool" "vm_pool" {
  name = var.pool_name
  type = "dir"

  target = {
    path = "${var.pool_path}/${var.pool_name}"
  }
}
