variable basename {}
variable resource_group_id {}
variable zone {}
variable cluster_worker_count {
  default = 2
}
variable cluster_flavor {
  default =  "cx2.2x4"
}
variable kube_version {
  default = "1.19"
}

resource "ibm_is_vpc" "vpc" {
  resource_group = var.resource_group_id
  name           = var.basename
}
# ----------------------
output name {
  value = ibm_container_vpc_cluster.cluster.name
}
output id {
  value = ibm_container_vpc_cluster.cluster.id
}

# ----------------------
# gateway needed for helm plugin to install container images for the storage class
resource "ibm_is_public_gateway" "public" {
  name           = "${var.basename}-public"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
}

resource "ibm_is_subnet" "subnet11" {
  name                     = "${var.basename}-1"
  resource_group = var.resource_group_id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.public.id
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.basename}-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  kube_version      = var.kube_version
  flavor            = var.cluster_flavor
  worker_count      = var.cluster_worker_count
  resource_group_id = var.resource_group_id

  zones {
    subnet_id = ibm_is_subnet.subnet11.id
    name      = var.zone
  }
}

