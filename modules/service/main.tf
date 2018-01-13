resource "aws_security_group" "instance_http" {
  vpc_id = "${var.vpc_id}"
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
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance_http.id}"]
  user_data = "${var.user_data}"
  name_prefix = "launch-config"
}

resource "aws_security_group" "elb_http" {
  vpc_id = "${var.vpc_id}"
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
  subnets = ["${var.subnet_ids}"]
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
  vpc_zone_identifier = ["${var.subnet_ids}"]
  health_check_type = "ELB"
}