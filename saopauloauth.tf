terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"   # <-- latest stable as of 2026
    }
  }
}
