# output "account_name" {
#   description = "The name of the Spacelift account"
#   value       = data.spacelift_account.this.name
# }

# output "github_integration" {
#   description = "The GitHub integration details"
#   value       = data.spacelift_github_enterprise_integration.github_enterprise_integration
# }

data "spacelift_ips" "all" {}

output "spacelift_cidr_ranges" {
  value = data.spacelift_ips.all.ips
}
