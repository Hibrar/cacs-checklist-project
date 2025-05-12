##This has been commented out since it is not required for use anymore - this was used when a standalone EC2 instance was used. However since AG is now being used, a static Elastic IP is no longer needed to be assigned

# #Allocating a static Elastic IP and associating it with the EC2 instance
# resource "aws_eip" "static_ip" {
#   instance = aws_instance.springboot_app.id
# }
#
# #Outputting the public IP of the EC2 instance
# output "ec2_static_ip" {
#   description = "Elastic IP of EC2"
#   value       = aws_eip.static_ip.public_ip
# }
