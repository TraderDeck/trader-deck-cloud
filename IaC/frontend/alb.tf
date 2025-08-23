resource "aws_lb" "internal_alb" {
  name               = "traderdeck-internal-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [data.aws_subnet.ec2_private_subnet_1.id, data.aws_subnet.ec2_private_subnet_2.id]

  enable_deletion_protection = false
  idle_timeout               = 120 
}

resource "aws_lb_target_group" "springboot_target" {
  name        = "traderdeck-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.existing_vpc.id
  target_type = "instance"

  health_check {
    path                = "/actuator/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"

    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ssl_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot_target.arn
  }

  depends_on = [aws_lb_target_group.springboot_target]
}

resource "aws_lb_target_group_attachment" "attach_springboot" {
  target_group_arn = aws_lb_target_group.springboot_target.arn
  target_id        = data.aws_instance.springboot.id
}

data "aws_acm_certificate" "ssl_cert" {
  domain   = "mytraderdeck.com" 
  statuses = ["ISSUED"]
  most_recent = true
}


data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["trader-deck-vpc"]
  }
}

data "aws_subnet" "ec2_private_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["subnet-1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id] 
  }
}

data "aws_subnet" "ec2_private_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["subnet-2"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id] 
  }
}

data "aws_instance" "springboot" {
  filter {
    name   = "tag:Name"
    values = ["TraderDeck-Backend"]
  }
}
