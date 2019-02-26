# Security Group - Allow HTTP, HTTPS for ELB
resource "aws_security_group" "sg-alb" {
    vpc_id = "${aws_vpc.vpc.id}"
    name = "${local.project_name}-sg-elb"
    description = "Allow HTTP/HTTPS traffic on ALB"

    ingress = {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress = {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress = {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags {
      Name = "sg-webserver-allow-ssh"
  }
}

resource "aws_security_group" "sg-ssh" {
    vpc_id = "${aws_vpc.vpc.id}"
    name = "${local.project_name}-sg-ssh"
    description = "Allow SSH to and from bastion host"

    ingress = {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["${var.BASTION_SG}"]
    }

    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

