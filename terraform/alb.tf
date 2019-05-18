
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

