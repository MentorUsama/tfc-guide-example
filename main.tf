# main.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

variable "delay_seconds" {
  type        = number
  description = "How many seconds to delay (applies to both apply and destroy)."
  default     = 10
}

# Delay resource
resource "time_sleep" "wait" {
  create_duration  = "${var.delay_seconds}s"
  destroy_duration = "${var.delay_seconds}s"

  # Log after apply delay
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Apply complete (slept ${var.delay_seconds}s)\""
  }

  # Log after destroy delay (NO var.* here, Terraform restriction)
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Destroy complete (slept during destroy)\""
  }
}

output "delay_applied_seconds" {
  value       = var.delay_seconds
  description = "Delay used for apply/destroy."
}
