# Creaete LB Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ext-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

# Cretae load balancer TG
resource "aws_lb_target_group" "alb-tg" {
  name     = "ALB-TargetGroup"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.hele-vpc.id

  stickiness {
    type = "lb_cookie"
  }
}

# Create Load Balancer and attach Target Group
resource "aws_lb" "ext-alb" {
  name               = "External-Load-Balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [aws_subnet.public-sn-01.id, aws_subnet.public-sn-02.id]
}