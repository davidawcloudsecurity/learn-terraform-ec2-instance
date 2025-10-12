# Variable definitions with type constraints and validations
# Demonstrates: Type Constraints, Custom Validations, Variable Types
 
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
 
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be valid (e.g., us-east-1, eu-central-1)."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}
