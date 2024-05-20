terraform {
  required_version = "~>1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.34.0"
    }
  }

   backend "s3" {
    bucket = "terraform-remotestatefile-s3"
    dynamodb_table = "terraform-state-locking"
    region = "eu-west-2"
   
  }
}