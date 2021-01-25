variable "ibmcloud_api_key" {
}

variable "basename" {
}

variable "resource_group" {
}

variable "imagefqn_nginx" {
}

variable "imagefqn_jekyll" {
}

# there are some dependencies on cluster creation must use us-south, look for dal10
variable "region" {
}

variable "cloudobjectstorage_plan" {
  default = "standard"
}

variable "cloudobjectstorage_location" {
  default = "global"
}

