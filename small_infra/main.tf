data "openstack_networking_network_v2" "ext_net" {
  name      = "Ext-Net"
  tenant_id = ""
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "tf-keypair"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "openstack_networking_port_v2" "public_port" {
  count          = var.nb
  name           = "tf-publicport-${format("%03d", count.index)}"
  network_id     = data.openstack_networking_network_v2.ext_net.id
  admin_state_up = "true"
}

resource "openstack_compute_instance_v2" "node" {
  count       = var.nb
  name        = "tf-instance-${format("%03d", count.index)}"
  image_name  = "Ubuntu 18.04"
  flavor_name = "s1-4"
  key_pair    = openstack_compute_keypair_v2.keypair.name
  network {
    port = openstack_networking_port_v2.public_port[count.index].id
  }

  lifecycle {
    ignore_changes = [user_data, image_id, key_pair]
  }
}

resource "openstack_blockstorage_volume_v2" "vol_node" {
  count       = var.nb
  name        = "tf-vol-${format("%03d", count.index)}"
  size        = 5
}

resource "openstack_compute_volume_attach_v2" "vol_node_attach" {
  count = var.nb

  instance_id = openstack_compute_instance_v2.node[count.index].id
  volume_id   = openstack_blockstorage_volume_v2.vol_node[count.index].id
}
