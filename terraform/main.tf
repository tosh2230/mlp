terraform {
  required_version = ">= 1.6.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.25.0"
    }
  }
  backend "s3" {
    # Replace this with your bucket name.
    bucket = "terraform-state-3516"
    key    = "mlp/terraform.tfstate"
    region = "ap-northeast-1"
  }
}


provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      project = local.project_name
    }
  }
}

locals {
  project_name = "mlp"
}
