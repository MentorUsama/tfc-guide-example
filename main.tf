# main.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

############################################
# Variables
############################################
variable "enabled" {
  type        = bool
  description = "If true, actually create AWS resources. Defaults to false (safe dry-run)."
  default     = false
}

variable "region" {
  type        = string
  description = "AWS region to use."
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (only used if enabled=true)."
  default     = "t3.micro"
}

variable "instance_name" {
  type        = string
  description = "Tag Name for the EC2 instance (only used if enabled=true)."
  default     = "test-ubuntu"
}

variable "delay_seconds" {
  type        = number
  description = "How many seconds to delay (applies to both apply and destroy)."
  default     = 10
}

############################################
# Providers
############################################
provider "aws" {
  region = var.region
}

############################################
# Simulated delay + logs (no cloud resources)
############################################
# This resource always exists (safe & free) and gives you a delay window and logs.
resource "time_sleep" "wait" {
  create_duration  = "${var.delay_seconds}s"
  destroy_duration = "${var.delay_seconds}s"

  # Log on apply (after the wait completes)
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Apply complete in ${var.enabled ? "REAL" : "DRY-RUN"} mode (slept ${var.delay_seconds}s)\""
  }

  # Log on destroy (after the wait completes)
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "echo \"[$(date -u +%FT%TZ)] Destroy complete in ${var.enabled ? "REAL" : "DRY-RUN"} mode (slept ${var.delay_seconds}s)\""
  }
}

############################################
# AWS bits (only if enabled)
############################################
data "aws_ami" "ubuntu" {
  count       = var.enabled ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  count         = var.enabled ? 1 : 0
  ami           = data.aws_ami.ubuntu[0].id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }

  # Optional: wait/log first, then create instance
  depends_on = [time_sleep.wait]
}

############################################
# Outputs
############################################
output "mode" {
  value       = var.enabled ? "REAL" : "DRY-RUN"
  description = "Indicates whether AWS resources were created."
}
output "delay_applied_seconds" {
  value       = var.delay_seconds
  description = "Delay used for apply/destroy."
}
