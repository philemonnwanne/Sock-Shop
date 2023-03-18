output "region" {
  description = "AWS region"
  value       = var.region
}

output "account_id" {
  value = local.account_id
}