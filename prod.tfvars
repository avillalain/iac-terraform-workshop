region = "us-east-1"
vpc_name = "terraform-workshop-prod"
cidr_block = "172.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b"]
subnet_cidr_blocks = {
  us-east-1a = "172.0.0.0/19",
  us-east-1b = "172.0.32.0/19"
}

min_size = 1
max_size = 5
desired_capacity = 2
instance_type = "t2.micro"