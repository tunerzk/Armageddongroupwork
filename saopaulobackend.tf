terraform {
  backend "s3" {
    bucket = "saopaulo-multiregion-tfstate"
    key    = "saopaulo/terraform.tfstate"
    region = "sa-east-1"
  }
}
