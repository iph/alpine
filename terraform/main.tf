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


variable "site_domain" {
  # I already own this domain in aws.
  default = "iph.io"
}


data "aws_acm_certificate" "website" {
  domain = "${tag}.${var.site_domain}"

  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "website" {
  name = "${tag}.${var.site_domain}."
}