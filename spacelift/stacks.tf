data "spacelift_github_enterprise_integration" "github_enterprise_integration" {}

resource "spacelift_stack" "storage-dev" {
  name     = "storage-dev"
  space_id = spacelift_space.storage-nonprod.id

  github_enterprise {
    id        = data.spacelift_github_enterprise_integration.github_enterprise_integration.id
    namespace = var.github_org_name
  }

  repository   = var.github_repository_name
  branch       = var.github_branch_name
  project_root = "terraform/envs/dev"

  terraform_version            = "1.5.7"
  terraform_workflow_tool      = "TERRAFORM_FOSS"
  terraform_smart_sanitization = true

  description                      = "Stack for storage resources DEV IaC (terraform)"
  labels                           = ["aws", "dev", "github", "terraform", "storage"]
  autodeploy                       = true
  additional_project_globs         = ["terraform/modules/**"]
  enable_well_known_secret_masking = true
  enable_local_preview             = true
  allow_run_promotion              = false
  #   import_state_file                = "../dev-terraform.tfstate"
}

# Attach the AWS integration to any stack(s) that need to use it
resource "spacelift_aws_integration_attachment" "storage-dev-stack" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.storage-dev.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this
  ]
}

resource "spacelift_context_attachment" "dev-terraform-context" {
  context_id = spacelift_context.dev-terraform.id
  stack_id   = spacelift_stack.storage-dev.id
}

resource "spacelift_stack" "storage-prod" {
  name     = "storage-prod"
  space_id = spacelift_space.storage-prod.id

  github_enterprise {
    id        = data.spacelift_github_enterprise_integration.github_enterprise_integration.id
    namespace = var.github_org_name
  }

  repository   = var.github_repository_name
  branch       = var.github_branch_name
  project_root = "terraform/envs/prod"

  terraform_version            = "1.5.7"
  terraform_workflow_tool      = "TERRAFORM_FOSS"
  terraform_smart_sanitization = true

  description                      = "Stack for storage resources PROD IaC (terraform)"
  labels                           = ["aws", "github", "prod", "terraform", "storage"]
  additional_project_globs         = ["terraform/modules/**"]
  enable_well_known_secret_masking = true
  allow_run_promotion              = false
  #   import_state_file                = "../prod-terraform.tfstate"
}

resource "spacelift_aws_integration_attachment" "storage-prod-stack" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.storage-prod.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this
  ]
}

resource "spacelift_stack_dependency" "storage-prod-stackdependency" {
  stack_id            = spacelift_stack.storage-prod.id
  depends_on_stack_id = spacelift_stack.storage-dev.id
}
