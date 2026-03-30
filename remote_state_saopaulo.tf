data "terraform_remote_state" "tokyo" {
  backend = "s3"
  config = {
    bucket = "saopaulo-multiregion-tfstate"
    key    = "tokyo/terraform.tfstate" # ← FIXED
    region = "sa-east-1"
  }
}
