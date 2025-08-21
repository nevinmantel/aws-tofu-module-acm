# 1. Certificates
resource "aws_acm_certificate" "this" {
  for_each = var.certs

  domain_name       = each.value.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  options {
    export = "ENABLED"
  }
}

# Route53 validation records (only if automatic DNS validation is selected)
resource "aws_route53_record" "validation" {
  for_each = {
    for k, v in aws_acm_certificate.this : k => v
    if var.certs[k].validation_method == "automatic"
  }

  zone_id = var.certs[each.key].zone_id
  name    = tolist(each.value.domain_validation_options)[0].resource_record_name
  type    = tolist(each.value.domain_validation_options)[0].resource_record_type
  records = [tolist(each.value.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

# ACM certificate validation (only for automatic DNS)
resource "aws_acm_certificate_validation" "this" {
  for_each = aws_route53_record.validation

  certificate_arn         = aws_acm_certificate.this[each.key].arn
  validation_record_fqdns = [each.value.fqdn]

  depends_on = [aws_route53_record.validation]
}