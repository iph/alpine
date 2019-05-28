# Not sure if provider or variables come first.
provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "gloomhaven-terraform-app-bucket"
    key    = "remote/states/state.tfstate"
    region = "us-west-2"
  }
}

module "routes" {
  source         = "./routes"
  region         = var.region
  tag            = var.tag
  stage          = var.stage
  default_domain = var.default_domain
}

module "vpc" {
  source   = "./vpc"
  az_count = var.az_count
  app_port = var.app_port
  tag      = var.tag
}
