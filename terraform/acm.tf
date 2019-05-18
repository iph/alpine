## Create all the necessary resources for route53 initial setup and shit.

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.tag}.${var.site_domain}"
  validation_method = "DNS"
}

resource "aws_route53_zone" "sub" {
  name = "${var.tag}.${var.site_domain}"

  tags = {
    Environment = var.tag
  }
}

resource "aws_route53_record" "tag-ns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.tag}.${var.site_domain}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.sub.name_servers.0}",
    "${aws_route53_zone.sub.name_servers.1}",
    "${aws_route53_zone.sub.name_servers.2}",
    "${aws_route53_zone.sub.name_servers.3}",
  ]
}

resource "aws_route53_record" "subdomain_cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.sub.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.subdomain_cert_validation.fqdn}",
  ]
}
