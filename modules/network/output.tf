output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "subnet_ids" {
  value = "${module.public_subnet.subnet_id}"
}