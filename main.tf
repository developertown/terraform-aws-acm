locals {
  enabled = var.enabled

  process_domain_validation_options = local.enabled && var.process_domain_validation_options && var.validation_method == "DNS"
  domain_validation_options_set     = local.process_domain_validation_options ? one(aws_acm_certificate.cert[*].domain_validation_options) : toset([])
  all_domains = concat(
    [var.domain_name],
    var.subject_alternative_names
  )

  domain_to_zone = {
    for domain in local.all_domains :
    domain => length(split(".", domain)) > 2 ? join(".", slice(split(".", domain), 1, length(split(".", domain)))) : domain
  }
  unique_zones = distinct(values(local.domain_to_zone))

  tags = merge(
    var.tags,
    {
      "Name"        = var.domain_name,
      "Environment" = var.environment,
      "ManagedBy"   = "Terraform"
    }
  )
}

resource "aws_acm_certificate" "cert" {
  count = local.enabled ? 1 : 0

  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "default" {
  for_each = local.process_domain_validation_options ? toset(local.unique_zones) : toset([])
  zone_id  = var.zone_id
  name     = try(length(var.zone_id), 0) == 0 ? (var.zone_name == "" ? each.key : var.zone_name) : null
}

resource "aws_route53_record" "default" {
  for_each = {
    for dvo in local.domain_validation_options_set : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.default[local.domain_to_zone[each.key]].id
  ttl             = var.ttl
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
}

resource "aws_route53_record" "parent_cert_validation" {
  for_each = {
    for dvo in one(aws_acm_certificate.cert[*].domain_validation_options) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(var.parent_subject_alternative_names, dvo.domain_name) && var.parent_dns_zone_id != ""
  }
  provider        = aws.parent_dns_zone_account
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.ttl
  type            = each.value.type
  zone_id         = var.parent_dns_zone_id
}

resource "aws_acm_certificate_validation" "default" {
  count = local.process_domain_validation_options && var.wait_for_certificate_issued ? 1 : 0

  certificate_arn         = join("", aws_acm_certificate.cert[*].arn)
  validation_record_fqdns = [for record in merge(aws_route53_record.default, var.parent_dns_zone_id != "" ? aws_route53_record.parent_cert_validation : null) : record.fqdn]
}

module "metric_alarm" {
  count = var.sns_alarm_topic_arn != "" ? 1 : 0

  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.2.0"

  alarm_name          = "ACM - Certificate Expiring"
  alarm_description   = "Certificate expiring ${var.alarm_expiration_threshold} days"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alarm_expiration_threshold
  period              = 86400

  namespace   = "AWS/CertificateManager"
  metric_name = "DaysToExpiry"
  statistic   = "Minimum"

  dimensions = {
    CertificateArn = one(aws_acm_certificate.cert[*].arn)
  }

  alarm_actions = [var.sns_alarm_topic_arn]
}
