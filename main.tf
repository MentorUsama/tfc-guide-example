terraform {
  required_version = ">= 1.5.0"
}

# Pure delay resource (safe; no cloud resources)
resource "time_sleep" "wait" {
  create_duration  = "${var.delay_seconds}s"
  destroy_duration = "${var.delay_seconds}s"

  # Log after apply delay
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Apply complete (slept ${var.delay_seconds}s)\""
  }

  # Log after destroy delay (no var.* allowed at destroy time)
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Destroy complete (delay executed)\""
  }
}
