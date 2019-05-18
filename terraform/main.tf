# Not sure if provider or variables come first.
provider "aws" {
  region = "${var.region}"
}


# Region to work in. Due to seattle living, us-west-2
# shall remain default forever.
variable "region" {
  default = "us-west-2"
}

# Tag is a concept I pulled over from my aws times
# where you essentially need a unique prefix to identify
# your concurrently running app, with everyone elses. It
# helps a lot, though in a fate of ironic justice, I made
# it so tags were randomly generated pet names like:
# "flying-bashful-yeti"
variable "tag" {
  type = "string"
}

variable "stage" {
  type    = "string"
  default = "dev" # Other one is prod
}

variable "default_domain" {
  # I already own this domain in aws.
  default = "iph.io"
}

locals {
  //site_domain = var.stage == "dev" ? "${var.tag}.${var.default_domain}" : "${var.default_domain}"
  site_domain = "${var.tag}.${var.default_domain}"
}


module "routes" {
  source         = "./routes"
  region         = var.region
  tag            = var.tag
  stage          = var.stage
  default_domain = var.default_domain
}
