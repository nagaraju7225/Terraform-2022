terraform {
  backend "s3" {
    bucket = "terraformbkp"
    key = "environments/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraformlocking"

  workspace_key_prefix = "lt-eapp-"
  }

}