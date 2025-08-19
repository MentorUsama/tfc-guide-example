# main.tf
terraform {
  required_version = ">= 1.5.0"
}

# How many seconds to delay (for both apply and destroy)
variable "delay_seconds" {
  type        = number
  description = "Delay applied during apply and destroy."
  default     = 10
}

# Pure delay resource (no cloud resources)
resource "time_sleep" "wait" {
  create_duration  = "${var.delay_seconds}s"
  destroy_duration = "${var.delay_seconds}s"

  # Log after apply delay
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Apply complete (slept ${var.delay_seconds}s)\""
  }

  # Log after destroy delay (must NOT reference var.* at destroy time)
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
