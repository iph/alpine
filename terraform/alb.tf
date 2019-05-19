
### ALB
resource "aws_alb" "main" {
  name            = "${var.tag}-alb"
  subnets         = "${module.vpc.public-subnets}"
  security_groups = ["${module.vpc.sg-lb}"]
}

resource "aws_alb_target_group" "app" {
  name        = "${var.tag}-main-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${module.vpc.vpc-id}"
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${module.routes.acm_certificate}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "redirect" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "sub-alb-record" {
  zone_id = "${module.routes.sub-record}"
  name    = "${module.routes.sub-domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.main.dns_name}"
    zone_id                = "${aws_alb.main.zone_id}"
    evaluate_target_health = false
  }
}