# Development Terraform Context just for demo purposes
resource "spacelift_context" "dev-terraform" {
  description = "Configuration details for the development Terraform environment"
  name        = "Development"
  space_id    = spacelift_space.infrastructure.id
  labels      = ["dev", "terraform"]
}

# ENV variable for the dev Terraform context just for demo purposes
resource "spacelift_environment_variable" "dev-environment" {
  context_id  = spacelift_context.dev-terraform.id
  name        = "TF_VAR_environment"
  value       = "dev"
  write_only  = false
  description = "Terraform environment variable for development"
}
