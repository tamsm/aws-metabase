// Resources:
// Aplication load balacner (ALB), ALB target group, ALB listener
resource "aws_alb" "metabase" {
  name               = var.project
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]

  tags = {
    Name = "${var.project}-alb"
    Env  = var.env
  }
}

resource "aws_alb_target_group" "metabase" {
  name        = var.project
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  // TODO: Read upon health checks
  health_check {
    path                = "/"
    port                = "3000"
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }
}

// Forward all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.metabase.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.metabase.arn
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
// Forward all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_ssl" {
  load_balancer_arn = aws_alb.metabase.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.certificate.arn
  default_action {
    target_group_arn = aws_alb_target_group.metabase.arn
    type             = "forward"
  }
  depends_on = [aws_acm_certificate.certificate]
}
resource "aws_lb_listener_certificate" "ssl_cert" {
  listener_arn    = aws_alb_listener.front_end_ssl.arn
  certificate_arn = aws_acm_certificate.certificate.arn
}