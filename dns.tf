data "aws_route53_zone" "default" {
  name = "nao42.com"
}

resource "aws_route53_record" "default" {
  zone_id = data.aws_route53_zone.default.id
  name    = data.aws_route53_zone.default.name
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = aws_route53_record.default.name
}

resource "aws_acm_certificate" "default" {
  domain_name               = aws_route53_record.default.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "default_certificate" {
  name    = tolist(aws_acm_certificate.default.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.default.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.default.domain_validation_options)[0].resource_record_value]
  zone_id = data.aws_route53_zone.default.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = [aws_route53_record.default_certificate.fqdn]
}
