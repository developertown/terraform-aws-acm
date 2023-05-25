variable "region" {
  type        = string
  description = "AWS Region to create resources in"
}

variable "tags" {
  description = "A set of key/value label pairs to assign to this to the resources"
  type        = map(string)
  default     = {}
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Set of domains that should be SANs in the issued certificate. A Route53 DNS validation record will be created for each subject_alternative_names in the aws account granted by role_arn"
  default     = []
}

variable "dns_name" {
  description = "The domain name for which the certificate should be issued. A certificate and a Route53 DNS validation record will be created in the aws account granted by role_arn"
  type        = string
}

variable "dns_zone_id" {
  description = "The ID of the Route53 hosted zone to contain the Certificate validation record for the dns_name and subject_alternative_names. The Route53 hosted zone must be accessible via the role_arn"
  type        = string
  default     = ""
}

variable "dns_ttl" {
  type        = number
  description = "The TTL to use for SSL certificates, and Route 53 records"
  default     = 60
}

variable "role_arn" {
  type        = string
  description = "The AWS assume role"
  default     = ""
}

variable "parent_dns_zone_id" {
  description = "The ID of the Route53 hosted zone to contain the Certificate validation record for the parent_subject_alternative_names. The Route53 hosted zone must be accessible via the parent_role_arn"
  type        = string
  default     = ""
}

variable "parent_subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate. A Route53 DNS validation record will be created for each parent_subject_alternative_names in the aws account granted by parent_role_arn"
  type        = list(string)
  default     = []
}

variable "parent_role_arn" {
  type        = string
  description = "The AWS assume role"
  default     = ""
}

variable "sns_alarm_topic_arn" {
  type        = string
  description = "The SNS Topic ARN to use for Cloudwatch Alarms"
  default     = ""
}

variable "alarm_expiration_threshold" {
  type        = number
  description = "Number of days before certificate expiration to trigger an alarm"
  default     = 14
}