# outputs.tf (test-only)
output "delay_applied_seconds" {
  value       = var.delay_seconds
  description = "Delay used for apply/destroy."
}
