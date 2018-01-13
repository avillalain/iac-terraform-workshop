provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_vpc" "this" {
  cidr_block = "${var.cidr_block}"
  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "this" {
  cidr_block = "${var.subnet_cidr_blocks}"
  availability_zone = "${var.availability_zones}"
  vpc_id = "${aws_vpc.this.id}"
  tags {
    Name = "${format("%s-subnet", var.vpc_name)}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags {
    Name = "${format("%s-igw", var.vpc_name)}"
  }
}

resource "aws_route_table" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags {
    Name = "${format("%s-route-table", var.vpc_name)}"
  }
}

resource "aws_route" "this" {
  route_table_id = "${aws_route_table.this.id}"
  gateway_id = "${aws_internet_gateway.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.this"]
}

resource "aws_route_table_association" "association" {
  route_table_id = "${aws_route_table.this.id}"
  subnet_id = "${aws_subnet.this.id}"
}