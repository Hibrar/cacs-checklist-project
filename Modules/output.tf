# #Output of the public IP address of the Spring Boot EC2 instance
# output "ec2_public_ip" {
#   description = "Public IP of the Spring Boot EC2 instance"
#   value = aws_instance.springboot_app.public_ip
# }

#Output the DNS name of the ALB
output "alb_dns_name" {
  description = "Public DNS of the ALB"
  value = aws_lb.springboot_alb.dns_name
}
