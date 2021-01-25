# A new cluster is created.  To use an existing cluster hard code the name of the existing cluster
locals {
  cluster_name = module.cluster.name
  # cluster_name = "existing cluster name"
}


# To replace the creation of a cluster with an existing cluster remove the stuff below
module "cluster" {
  source = "./cluster"
  basename = var.basename
  resource_group_id = data.ibm_resource_group.group.id
}

