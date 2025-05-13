# output "ec2_public_ip" {
#   value = module.cacs_checklist_module.ec2_public_ip
# }

output "alb_dns_name" {
  value = module.cacs_checklist_module.alb_dns_name
  description = "Public DNS of the ALB"
}

# output "mongodb_connection_info" {
#   value = "mongodb://<hidden-username>:<hidden-password>@${aws_instance.mongodb_ec2.public_ip}:27017"
# }
#
