# Application Load Balancer: LB, TargetGroup, TargetGroupAttachment, Listener

resource "aws_alb" "app-loadbalancer" {
    name = "${local.project_name}-alb"
    subnets = ["${aws_subnet.public-1.id}", "${aws_subnet.public-2.id}", "${aws_subnet.public-3.id}"]
    security_groups = ["${aws_security_group.sg-alb.id}"]

    tags {
        Name = "${local.project_name}-alb"
    }
}

resource "aws_alb_target_group" "alb-target" {
    name = "${local.project_name}-alb-tg-01"
    port = 443
    protocol = "HTTPS"
    vpc_id = "${aws_vpc.vpc.id}"

    health_check {
        path = "/healthcheck"
        port = "80"
        protocol = "HTTP"
        healthy_threshold = 5
        unhealthy_threshold = 2
        interval = 30
        timeout = 5
    }
}

resource "aws_alb_target_group_attachment" "alb-target-attachment-1" {
  target_group_arn = "${aws_alb_target_group.alb-target.arn}"
  target_id = "${aws_instance.web-01.id}"
  port = 80
}

resource "aws_alb_target_group_attachment" "alb-target-attachment-2" {
  target_group_arn = "${aws_alb_target_group.alb-target.id}"
  target_id = "${aws_instance.app-01.id}"
  port = 80
}

resource "aws_alb_listener" "alb-frontend-listeners" {
  "default_action" {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.alb-target.arn}"
  }
  load_balancer_arn = "${aws_alb.app-loadbalancer.arn}"
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${aws_acm_certificate.acm-cert.arn}"
}

resource "aws_alb_listener_certificate" "alb-https-cert" {
  certificate_arn = "${aws_acm_certificate.acm-cert.arn}"
  listener_arn = "${aws_alb_listener.alb-frontend-listeners.arn}"
}

resource "aws_acm_certificate" "acm-cert" {
  domain_name = "${var.DOMAIN_NAME}"
  validation_method = "DNS"
  tags {
    Name = "${local.project_name}-cert"
  }
  lifecycle {
    create_before_destroy = true
  }
}



