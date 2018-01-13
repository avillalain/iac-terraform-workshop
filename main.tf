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

resource "aws_security_group" "instance_http" {
  vpc_id = "${aws_vpc.this.id}"
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "this" {
  image_id = "${data.aws_ami.ec2_ami.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance_http.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  name_prefix = "launch-config"
}

resource "aws_security_group" "elb_http" {
  vpc_id = "${aws_vpc.this.id}"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "this" {
  name_prefix = "elb"
  subnets = ["${aws_subnet.this.id}"]
  security_groups = ["${aws_security_group.elb_http.id}"]
  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
}

resource "aws_autoscaling_group" "this" {
  launch_configuration = "${aws_launch_configuration.this.name}"
  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"
  load_balancers = ["${aws_elb.this.name}"]
  vpc_zone_identifier = ["${aws_subnet.this.id}"]
  health_check_type = "ELB"
}

output "svc_url" {
  value = "${aws_elb.this.dns_name}"
}