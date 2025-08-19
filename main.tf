terraform {
  required_version = ">= 1.5.0"
}

variable "delay_seconds" {
  type        = number
  description = "Delay applied during apply and destroy."
  default     = 10
}

resource "time_sleep" "wait" {
  create_duration  = "${var.delay_seconds}s"
  destroy_duration = "${var.delay_seconds}s"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Apply complete (slept ${var.delay_seconds}s)\""
  }

  # Must not reference var.* at destroy time
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Destroy complete (delay executed)\""
  }
}
