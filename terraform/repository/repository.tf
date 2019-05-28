// Note: This should only be generated once per account.
provider "aws" {
  region = "${var.region}"
}

variable "region" {
  default = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "gloomhaven-terraform-app-bucket"
    key    = "remote/states/repository.tfstate"
    region = "us-west-2"
  }
}

resource "aws_ecr_repository" "main-repo" {
  name = "gloomhaven-images"
}