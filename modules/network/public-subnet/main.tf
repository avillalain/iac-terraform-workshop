resource "aws_subnet" "this" {
  count = "${length(var.availability_zones)}"
  cidr_block = "${var.subnet_cidr_blocks[var.availability_zones[count.index]]}"
  availability_zone = "${var.availability_zones[count.index]}"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${format("%s-%s-subnet", var.vpc_name, var.availability_zones[count.index])}"
  }
}

resource "aws_internet_gateway" "this" {
  count = "${length(var.availability_zones) > 0 ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${format("%s-igw", var.vpc_name)}"
  }
}

resource "aws_route_table" "this" {
  count = "${length(var.availability_zones) > 0 ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${format("%s-route-table", var.vpc_name)}"
  }
}

resource "aws_route" "this" {
  count = "${length(var.availability_zones) > 0 ? 1 : 0}"
  route_table_id = "${aws_route_table.this.id}"
  gateway_id = "${aws_internet_gateway.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.this"]
}

resource "aws_route_table_association" "association" {
  count = "${length(var.availability_zones)}"
  route_table_id = "${aws_route_table.this.id}"
  subnet_id = "${element(aws_subnet.this.*.id, count.index)}"
}