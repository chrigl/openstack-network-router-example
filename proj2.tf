resource "openstack_networking_network_v2" "proj2" {
  name = "proj2"
}

resource "openstack_networking_subnet_v2" "proj2" {
  name       = "proj2"
  network_id = openstack_networking_network_v2.proj2.id

  ip_version = 4
  cidr       = "10.10.2.0/24"
}

resource "openstack_networking_router_v2" "proj2" {
  name = "proj2"

  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "proj2" {
  router_id = openstack_networking_router_v2.proj2.id
  subnet_id = openstack_networking_subnet_v2.proj2.id
}

resource "openstack_networking_secgroup_v2" "proj2" {
  name = "proj2"
}

resource "openstack_networking_secgroup_rule_v2" "proj2_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "22"
  port_range_max    = "22"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.proj2.id
}

resource "openstack_networking_secgroup_rule_v2" "proj2_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.proj2.id
}

resource "openstack_compute_instance_v2" "proj2" {
  name     = "server-proj2"
  key_pair = var.key_pair

  image_name      = var.image_name
  flavor_name     = "m1.small"
  security_groups = ["default", openstack_networking_secgroup_v2.proj2.name]
  network {
    uuid = openstack_networking_network_v2.proj2.id
  }
}

resource "openstack_networking_floatingip_v2" "proj2" {
  pool = "provider"
}

resource "openstack_compute_floatingip_associate_v2" "server_proj2" {
  floating_ip = openstack_networking_floatingip_v2.proj2.address
  instance_id = openstack_compute_instance_v2.proj2.id
}
