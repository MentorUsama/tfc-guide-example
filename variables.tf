variable "delay_seconds" { 
  type = number 
  description = "Delay applied during apply and destroy." default = 10 
}

variable "force_fail" {
  type        = bool
  description = "Set to true to force an error during plan (for testing)."
  default     = true
}

locals {
  # If force_fail = true, this triggers a plan-time error
  intentional_error = var.force_fail ? file("nonexistent.file") : ""
}
