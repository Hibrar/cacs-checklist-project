output "ec2_public_ip" {
  value = module.cacs_checklist_module.ec2_public_ip
}

output "alb_dns_name" {
  value = module.cacs_checklist_module.alb_dns_name
}
