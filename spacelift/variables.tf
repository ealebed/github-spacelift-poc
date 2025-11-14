variable "api_key_endpoint" {
  type    = string
  default = "https://ealebed.app.spacelift.io"
}

variable "spacelift_key_id" {
  type = string
}

variable "spacelift_key_secret" {
  type = string
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "github_org_name" {
  type        = string
  description = "The GitHub organization name for the integration in Spacelift"
  default     = "ealebed"
}

variable "github_repository_name" {
  type        = string
  description = "The GitHub repository name for the integration in Spacelift"
  default     = "github-spacelift-poc"
}

variable "github_branch_name" {
  type        = string
  description = "The GitHub branch name for the integration in Spacelift"
  default     = "master"
}
