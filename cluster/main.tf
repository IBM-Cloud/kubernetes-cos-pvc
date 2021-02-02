data "ibm_resource_group" "group" {
  name = var.resource_group
}

locals {
  resource_group_id = data.ibm_resource_group.group.id
  zone              = "${var.region}-1"
}

resource "ibm_is_vpc" "vpc" {
  resource_group = local.resource_group_id
  name           = var.basename
}

# ----------------------
# gateway needed for helm plugin to install container images for the storage class and to use 
# hub.docker.io instead of the IBM Container Registry
resource "ibm_is_public_gateway" "public" {
  name           = "${var.basename}-public"
  resource_group = local.resource_group_id
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.zone
}

resource "ibm_is_subnet" "subnet11" {
  name                     = "${var.basename}-1"
  resource_group           = local.resource_group_id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.zone
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.public.id
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.basename}-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  kube_version      = var.kube_version
  flavor            = var.cluster_flavor
  worker_count      = var.cluster_worker_count
  resource_group_id = local.resource_group_id

  zones {
    subnet_id = ibm_is_subnet.subnet11.id
    name      = local.zone
  }
}

# ----------------------
output "name" {
  value = ibm_container_vpc_cluster.cluster.name
}
