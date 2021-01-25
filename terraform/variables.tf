variable "ibmcloud_api_key" {
}

variable "basename" {
}

variable "resource_group" {
}

variable "imagefqn" {
}

variable "cloudobjectstorage_plan" {
  default = "standard"
}

variable "cloudobjectstorage_location" {
  default = "global"
}

# there are some dependencies on cluster creation must use us-south, look for dal10
variable "region" {
  default = "us-south"
}

