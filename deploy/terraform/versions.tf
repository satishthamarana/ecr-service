terraform {
    required_version = ">=1.1"
    backend "s3" {
      bucket = "placeholder"
      key    = "placeholder.tfstate"
      region = "placeholder"
    }
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}