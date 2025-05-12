
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-sg"
  description = "Allow SSH and MongoDB access from my IP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongodb_ec2" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  key_name               = "terraform_access" # Replace with your actual key pair name
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  iam_instance_profile = aws_iam_instance_profile.cacs_instance_profile.name

  tags = {
    Name = "MongoDB-EC2"
  }
}

resource "null_resource" "mongo_setup" {
  depends_on = [aws_instance.mongodb_ec2]
#Updated private key
  connection {
    type        = "ssh"
    host        = aws_instance.mongodb_ec2.public_ip
    user        = "ec2-user"
    private_key = var.ssh_private_key


  }

  provisioner "remote-exec" {
    inline = [
      "set -e",

      "cat <<EOF | sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo",
      "[mongodb-org-8.0]",
      "name=MongoDB Repository",
      "baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/8.0/x86_64/",
      "gpgcheck=1",
      "enabled=1",
      "gpgkey=https://pgp.mongodb.com/server-8.0.asc",
      "EOF",

      "echo 'Sleeping to allow repo sync...'",
      "sleep 10",

      "sudo yum clean all",
      "sudo yum makecache --refresh",
      "sudo yum install -y mongodb-org",

      "sudo systemctl enable mongod",
      "sudo systemctl start mongod",
      "sleep 10",
      "sudo yum install -y jq",

      "SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id mongodb-credentials --query SecretString --output text)",
      "USERNAME=$(echo $SECRET_JSON | jq -r .username)",
      "PASSWORD=$(echo $SECRET_JSON | jq -r .password)",
      "mongosh --eval \"db.getSiblingDB('admin').createUser({user:'$USERNAME',pwd:'$PASSWORD',roles:[{role:'userAdminAnyDatabase',db:'admin'},{role:'readWriteAnyDatabase',db:'admin'}]})\"",

      "sudo sed -i '/^#*security:/,/^[^ ]/d' /etc/mongod.conf",
      "echo -e '\nsecurity:\n  authorization: enabled' | sudo tee -a /etc/mongod.conf",
      "sudo sed -i 's/^  bindIp: .*/  bindIp: 0.0.0.0/' /etc/mongod.conf",

      "sudo systemctl restart mongod"
    ]
  }
}

# output "mongodb_connection_info" {
#   value = "mongodb://<hidden-username>:<hidden-password>@${aws_instance.mongodb_ec2.public_ip}:27017"
# }

