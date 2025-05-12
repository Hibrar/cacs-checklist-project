# Creating a security group for the EC2 instance and ALB
resource "aws_security_group" "allow_tls" {
  name = "web_sg"
  description = "Allow HTTP and SSH"
  vpc_id = data.aws_vpc.default.id

#Allowing inbound SSH access on port 22
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Allow inbound HTTP traffic on port 80
  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServerSG"
  }
}
