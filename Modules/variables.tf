#Defining the EC2 instance type
variable "instance_type" {
  default = "t2.micro"
}

#Name of the SSH key pair to access the EC2 instance
variable "key_name" {
  default = "terraform_access"
}
