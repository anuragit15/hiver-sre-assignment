provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "~/.aws/credentials"
}

data "aws_vpc" "default_vpc" {
  default = true
}

output "default_vpc_id" {
  value = data.aws_vpc.default_vpc.id
}

/*
This although valid was throwing an error, resolution used below

resource "aws_security_group" "prod_sg" {
  name = "prod-web-servers-sg"
  vpc_id = data.aws_vpc.default_vpc.id
  ingress = [ {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  },
  {
    description = "https"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  } ]
}
*/

locals {
  ports_in = [
      80,
      443
  ]
}

resource "aws_security_group" "prod-ws-sg" {
  name = "prod-web-servers-sg"
  vpc_id = data.aws_vpc.default_vpc.id
  dynamic "ingress" {
      for_each = toset(local.ports_in)
      content {
          description = "http/https from anywhere"
          from_port = ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
      }
  }
}

data "aws_subnets" "vpc_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

output "vpc_subnet_ids" {
  value = data.aws_subnets.vpc_subnets.ids
}

output "sg-id" {
  value = aws_security_group.prod-ws-sg.id
}

resource "aws_lb" "prod-nlb" {
  name = "prod-web-servers-nlb"
  internal = false
  load_balancer_type = "network"
  subnets = data.aws_subnets.vpc_subnets.ids
}

data "aws_ami" "public_ubuntu_ami" {
  most_recent = true
  filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
      name = "virtualization-type"
      values = ["hvm"]
  }
  owners = ["099720109477"] # Cannonical's owner id
}

resource "aws_instance" "prod-ec2-servers" {
  for_each = toset(["1", "2"])
  ami = data.aws_ami.public_ubuntu_ami.id
  associate_public_ip_address = false
  instance_type = "t3.large"
  security_groups = ["aws_security_group.prod-ws-sg.id"]
  subnet_id = data.aws_subnets.vpc_subnets.ids[0]
  tags = {
    "Name" = "prod-web-server-${each.key}"
  }
}

resource "aws_lb_target_group" "prod-nlb-tg" {
  name = "prod-nlb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_lb_listener" "prod-nlb-listener" {
  load_balancer_arn = aws_lb.prod-nlb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.prod-nlb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "prod-nlb-tg-attach" {
  for_each = aws_instance.prod-ec2-servers
  target_group_arn = aws_lb_target_group.prod-nlb-tg.arn
  target_id = each.value.id
}