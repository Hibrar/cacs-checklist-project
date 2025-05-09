#Creating a target group for the Spring Boot app
resource "aws_lb_target_group" "springboot_tg" {
  name = "springboot-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = data.aws_vpc.default.id

  #Health check settings to monitor the EC2 instance availability
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "springboot-target-group"
  }
}

/*
1.create a target group
2.the name which will show in the aws console
3.the app listens on port80 and requests will be sent to port 80 on the ec2
4.EC2 instances are directly targeted NOT CONTAINERS OR IPs
5.target group must exist inside a VPC, automatically using default VPC from data.tf
6.health check - ALB sents HTTP requests on each instance, which is only considered healthy if "HTTP 200 (OK)" is returned. every 30 seconds the health is checked and there is a wait time of 5 seconds before the test is failed.
2 checks in a row must be passed to be healthy. 2 fails ina row means unhealthy.

 **The ALB only sends traffic to healthy instances. if the EC2 app crashes, it ownt receive traffic**
 */

#Creating the ALB
resource "aws_lb" "springboot_alb" {
  name = "springboot-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_tls.id]
  subnets = data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = {
    Name = "springboot-alb"
  }
}

# Defining a listener for the ALB to listen on port 80 HTTP
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.springboot_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.springboot_tg.arn
  }
}

#Attaching the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.springboot_tg.arn
  target_id = aws_instance.springboot_app.id
  port = 80
}
