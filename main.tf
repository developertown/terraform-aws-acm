resource "aws_acm_certificate" "cert" {
  domain_name               = var.dns_name
  subject_alternative_names = concat(var.parent_subject_alternative_names, var.subject_alternative_names)
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if dvo.domain_name == var.dns_name && var.dns_zone_id != ""
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.dns_ttl
  type            = each.value.type
  zone_id         = var.dns_zone_id
}

resource "aws_route53_record" "subject_alternative_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(var.subject_alternative_names, dvo.domain_name) && var.dns_zone_id != ""
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.dns_ttl
  type            = each.value.type
  zone_id         = var.dns_zone_id
}

resource "aws_route53_record" "parent_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(var.parent_subject_alternative_names, dvo.domain_name) && var.parent_dns_zone_id != ""
  }
  provider        = aws.parent_dns_zone_account
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.dns_ttl
  type            = each.value.type
  zone_id         = var.parent_dns_zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in merge(
    aws_route53_record.parent_cert_validation,
    aws_route53_record.cert_validation,
    aws_route53_record.subject_alternative_validation,
  ) : record.fqdn]
}

module "metric_alarm" {
  count   = var.sns_alarm_topic_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.2.0"

  alarm_name          = "ACM - Certificate Expiring - ${var.dns_name}"
  alarm_description   = "Certificate expiring ${var.alarm_expiration_threshold} days"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alarm_expiration_threshold
  period              = 86400

  namespace   = "AWS/CertificateManager"
  metric_name = "DaysToExpiry"
  statistic   = "Minimum"

  dimensions = {
    CertificateArn = aws_acm_certificate.cert.arn
  }

  alarm_actions = [var.sns_alarm_topic_arn]
}
