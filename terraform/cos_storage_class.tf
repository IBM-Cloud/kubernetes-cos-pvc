# If the existing cluster already has the cos storage classes installed delete this file
#
# Install the cos storage class into the cluster.
#
# Note this is currently hard coded to region=us-south

provider "helm" {
  kubernetes {
    config_path = data.ibm_container_cluster_config.cluster.config_file_path
  }
}

# To replace the creation of a cluster with an existing cluster remove the stuff below
module "cos_storage_class" {
  source = "./cos_storage_class"
}
