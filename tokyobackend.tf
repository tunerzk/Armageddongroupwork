terraform {
  backend "s3" {
    bucket = "saopaulo-multiregion-tfstate"
    key    = "tokyo/terraform.tfstate"
    region = "sa-east-1"
  }
}
