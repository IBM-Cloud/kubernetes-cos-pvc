variable "ibmcloud_api_key" {
}

variable "basename" {
}

variable "resource_group" {
}

variable "region" {
}

variable cluster_name {
}

variable cluster_worker_count {
  default = 2
}
variable cluster_flavor {
  default =  "cx2.2x4"
}
variable kube_version {
  default = "1.19"
}
