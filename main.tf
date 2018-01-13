terraform {
  backend "s3" {
    bucket = "demo-iac-terraform"
    key = "infrastructure"
    region = "us-east-1"
    profile = "simplicity"
  }
}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_ami" "ec2_ami" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial*"]
  }
  filter {
    name = "architecture"
    values = [
      "x86_64"]
  }
  filter {
    name = "hypervisor"
    values = [
      "xen"]
  }
  filter {
    name = "root-device-type"
    values = [
      "ebs"
    ]
  }
  owners = [
    "099720109477"]
}

module "network" {
  source = "modules/network"
  vpc_name = "${var.vpc_name}"
  cidr_block = "${var.cidr_block}"
  subnet_cidr_blocks = "${var.subnet_cidr_blocks}"
  availability_zones = "${var.availability_zones}"
}

module "service" {
  source = "modules/service"
  ami_id = "${data.aws_ami.ec2_ami.id}"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  vpc_id = "${module.network.vpc_id}"
  subnet_ids = "${module.network.subnet_ids}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  instance_type = "${var.instance_type}"
}

output "service" {
  value = "${module.service.url}"
}