module "vpc" {
  source = "./vpc"
  vpc_name = "${var.vpc_name}"
  cidr_block = "${var.cidr_block}"
}

module "public_subnet" {
  source = "./public-subnet"
  subnet_cidr_blocks = "${var.subnet_cidr_blocks}"
  availability_zones = "${var.availability_zones}"
  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.vpc.vpc_id}"
}