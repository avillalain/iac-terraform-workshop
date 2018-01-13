variable "secret_key" {
  type = "string"
}

variable "access_key" {
  type = "string"
}

variable "region" {
  type = "string"
  default = "us-east-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_s3_bucket" "this" {
  bucket = "demo-iac-terraform"
  region = "${var.region}"
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}