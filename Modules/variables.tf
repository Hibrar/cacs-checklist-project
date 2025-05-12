#Defining the EC2 instance type
variable "instance_type" {
  default = "t2.micro"
}

#Name of the SSH key pair to access the EC2 instance
variable "key_name" {
  default = "terraform_access"
}

# variable "db_username" {
#   description = "The database admin username"
#   type        = string
#   sensitive   = true
# }
#
# variable "db_password" {
#   description = "The database admin password"
#   type        = string
#   sensitive   = true
# }

variable "api_token" {
  description = "API token for integration"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "The private key for MongoDB EC2 SSH access"
  type        = string
  sensitive   = true
}
