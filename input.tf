variable "secret_key" {
  type = "string"
}

variable "access_key" {
  type = "string"
}

variable "cidr_block" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "subnet_cidr_blocks" {
  type = "map"
}

variable "availability_zones" {
  type = "list"
}

variable "min_size" {
  type = "string"
}

variable "max_size" {
  type = "string"
}

variable "desired_capacity" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}