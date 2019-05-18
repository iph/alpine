## Create all the necessary resources for route53 initial setup and shit.
variable "region" {}
variable "default_domain" {}
variable "tag" {}
variable "stage" {}

locals {
  //site_domain = var.stage == "dev" ? "${var.tag}.${var.default_domain}" : "${var.default_domain}"
  site_domain = "${var.tag}.${var.default_domain}"
}

## Main domain that should already be setpu if you bought a uri already.
data "aws_route53_zone" "main" {
  name         = "${var.default_domain}."
  private_zone = false
}


resource "aws_acm_certificate" "cert" {
  domain_name       = local.site_domain
  validation_method = "DNS"
}

resource "aws_route53_zone" "sub-domain" {
  name = local.site_domain

  tags = {
    Environment = var.tag
  }
}

resource "aws_route53_record" "sub-zone" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.site_domain
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.sub-domain.name_servers.0}",
    "${aws_route53_zone.sub-domain.name_servers.1}",
    "${aws_route53_zone.sub-domain.name_servers.2}",
    "${aws_route53_zone.sub-domain.name_servers.3}",
  ]
}

resource "aws_route53_record" "subdomain_cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.sub-domain.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.subdomain_cert_validation.fqdn}",
  ]
}

output "acm_certificate" {
  value = "${aws_acm_certificate.cert.arn}"
}