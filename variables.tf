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
variable "ssh_private_key" {
  description = "The private key for MongoDB EC2 SSH access"
  type        = string
  sensitive   = true
}

variable "api_token" {
  description = "API token for integration"
  type        = string
  sensitive   = true
}