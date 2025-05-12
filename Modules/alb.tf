## Launch Template
# Blueprint for EC2 instance creation
resource "aws_launch_template" "springboot_lt" {
  name_prefix   = "springboot-lt-"
  image_id      = data.aws_ami.get_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name


    iam_instance_profile {
    name = aws_iam_instance_profile.cacs_instance_profile.name
  }



  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "springboot-instance"
    }
  }
}

##Auto Scalign Group
# Automatically creating and managing EC2 instance
resource "aws_autoscaling_group" "springboot_asg" {
  name                      = "springboot-asg"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = data.aws_subnets.public.ids
  health_check_type         = "EC2"
  health_check_grace_period = 30
  force_delete              = true
#Linking the AG to the launch template
  launch_template {
    id      = aws_launch_template.springboot_lt.id
    version = "$Latest"
  }
# Attaching the ASG to the Target Group for the ALB
  target_group_arns = [aws_lb_target_group.springboot_tg.arn]

  tag {
    key                 = "Name"
    value               = "springboot-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


#Creating a target group for the Spring Boot app - Communicates to the ALB where to sent the traffic (port 80)
resource "aws_lb_target_group" "springboot_tg" {
  name = "springboot-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = data.aws_vpc.default.id

  #Health check settings to monitor if the instance is working
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

#Creating the ALB - Handles traffic and sends it to healthy instances
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

##This is the EC2 Direct Attachment - this was used when there was a single EC2 instance however since ASG is used, this code is not needed
# #Attaching the EC2 instance to the target group
# resource "aws_lb_target_group_attachment" "ec2_attachment" {
#   target_group_arn = aws_lb_target_group.springboot_tg.arn
#   target_id = aws_instance.springboot_app.id
#   port = 80
# }
