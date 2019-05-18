# Not sure if provider or variables come first.
provider "aws" {
  region = "${var.region}"
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
