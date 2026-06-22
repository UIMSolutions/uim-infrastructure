terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  description = "Target environment identifier"
  type        = string
  default     = "dev"
}

output "environment" {
  value = var.environment
}