terraform {
  required_version = ">= 1.5.0"
}

resource "time_sleep" "wait" {
  create_duration  = "${var.delay_seconds}s"
  destroy_duration = "${var.delay_seconds}s"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Apply complete (slept ${var.delay_seconds}s)\""
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Destroy complete (delay executed)\""
  }
}

# Force plan-time failure if enabled
locals {
  intentional_error = var.force_fail ? file("nonexistent.file") : ""
}
