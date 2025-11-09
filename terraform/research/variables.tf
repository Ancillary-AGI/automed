variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges for cluster access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}