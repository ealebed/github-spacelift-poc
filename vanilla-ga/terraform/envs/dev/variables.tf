variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "vanilla-ga"
}
