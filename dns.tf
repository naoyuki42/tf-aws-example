data "aws_route53_zone" "default" {
  name = "nao42.com"
}

resource "aws_route53_zone" "test_default" {
  name = "test.nao42.com"
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
