# ALB + target group + listener

### ALB ######################################################

resource "aws_lb" "alb-param" {
    name            = "alb-backend-tf"
    internal        = false
    ip_address_type     = "ipv4"
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb-sg-param.id]
    subnets = [
                aws_subnet.public-snet-param-1a.id,
                aws_subnet.public-snet-param-1b.id
                ]
    tags = {
        Name = "alb-backend-tf"
    }
}

### Target Group ############################################

resource "aws_lb_target_group" "tg-param" {
  name     = "tg-backend-tf"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_param.id
  target_type = "instance"

    # Health check configuration
    health_check {
        enabled             = true
        path                = "/healthcheck"
        port                = "traffic-port"
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
    }
}

# Register specific instances
resource "aws_lb_target_group_attachment" "tg-attachment-1" {
  target_group_arn = aws_lb_target_group.tg-param.arn
  target_id        = aws_instance.ec2-backend-param["1a"].id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "tg-attachment-2" {
  target_group_arn = aws_lb_target_group.tg-param.arn
  target_id        = aws_instance.ec2-backend-param["1b"].id
  port             = 8080
}

### Listener ################################################

resource "aws_lb_listener" "alb-listener-param" {
    load_balancer_arn          = aws_lb.alb-param.arn
    port                       = 80
    protocol                   = "HTTP"
    default_action {
        target_group_arn         = aws_lb_target_group.tg-param.arn
        type                     = "forward"
    }
}