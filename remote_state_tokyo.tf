data "terraform_remote_state" "saopaulo" {
  backend = "s3"
  config = {
    bucket = "saopaulo-multiregion-tfstate"
    key    = "saopaulo/terraform.tfstate"
    region = "sa-east-1"
  }
}
