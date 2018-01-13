variable "ami_id" {
  type = "string"
}

variable "user_data" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "string"
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