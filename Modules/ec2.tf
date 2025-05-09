# Launch EC2 instance for the Sprign Boot application
resource "aws_instance" "springboot_app" {
  ami = data.aws_ami.get_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = var.key_name

  tags = {
    Name = "springboot-app-dev"
  }
}
