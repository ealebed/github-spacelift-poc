provider "aws" {
  region = var.aws_region
}

module "core" {
  source = "../../modules/core"

  environment  = var.environment
  project_name = var.project_name
}
