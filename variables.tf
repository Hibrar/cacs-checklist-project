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