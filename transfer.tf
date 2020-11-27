resource "openstack_networking_network_v2" "transfer" {
  name = "transfer"
}

resource "openstack_networking_subnet_v2" "transfer" {
  name       = "transfer"
  network_id = openstack_networking_network_v2.transfer.id

  ip_version = 4
  no_gateway = true
  enable_dhcp = false
  cidr       = "10.0.0.0/30"
}

# This is a little bit hacky, but works around "gateway" issues
resource "openstack_networking_port_v2" "transfer_proj1" {
  network_id            = openstack_networking_network_v2.transfer.id
  port_security_enabled = false

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer.id
    ip_address = "10.0.0.1"
  }
}

resource "openstack_networking_port_v2" "transfer_proj2" {
  network_id            = openstack_networking_network_v2.transfer.id
  port_security_enabled = false

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer.id
    ip_address = "10.0.0.2"
  }
}

resource "openstack_networking_router_interface_v2" "transfer_proj1" {
  depends_on = [openstack_networking_port_v2.transfer_proj1]

  router_id = openstack_networking_router_v2.proj1.id
  port_id   = openstack_networking_port_v2.transfer_proj1.id
}

resource "openstack_networking_router_interface_v2" "transfer_proj2" {
  depends_on = [openstack_networking_port_v2.transfer_proj2]

  router_id = openstack_networking_router_v2.proj2.id
  port_id   = openstack_networking_port_v2.transfer_proj2.id
}

resource "openstack_networking_router_route_v2" "proj1_to_proj2" {
  depends_on = [openstack_networking_router_interface_v2.transfer_proj1, openstack_networking_router_interface_v2.transfer_proj2]

  router_id        = openstack_networking_router_v2.proj1.id
  next_hop         = openstack_networking_port_v2.transfer_proj2.fixed_ip[0].ip_address
  destination_cidr = openstack_networking_subnet_v2.proj2.cidr
}

resource "openstack_networking_router_route_v2" "proj2_to_proj1" {
  depends_on = [openstack_networking_router_interface_v2.transfer_proj1, openstack_networking_router_interface_v2.transfer_proj2]

  router_id        = openstack_networking_router_v2.proj2.id
  next_hop         = openstack_networking_port_v2.transfer_proj1.fixed_ip[0].ip_address
  destination_cidr = openstack_networking_subnet_v2.proj1.cidr
}
