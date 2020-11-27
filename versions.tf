terraform {
  required_providers {
    openstack = {
      source  = "terraform-providers/openstack"
      version = "~> 1.30.0"
    }
  }
  required_version = ">= 0.13"
}
