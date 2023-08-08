variable "subject_alternative_names" {
  type        = list(string)
  description = "Set of domains that should be SANs in the issued certificate. A Route53 DNS validation record will be created for each subject_alternative_names in the aws account granted by role_arn"
  default     = []
}

variable "domain_name" {
  description = "The domain name for which the certificate should be issued. A certificate and a Route53 DNS validation record will be created in the aws account granted by role_arn"
  type        = string
}

variable "dns_zone_id" {
  description = "The ID of the Route53 hosted zone to contain the Certificate validation record for the dns_name and subject_alternative_names. The Route53 hosted zone must be accessible via the role_arn"
  type        = string
  default     = ""
}

variable "ttl" {
  type        = number
  description = "The TTL to use for SSL certificates, and Route 53 records"
  default     = 60
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

variable "process_domain_validation_options" {
  type        = bool
  default     = true
  description = "Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation"
}

variable "validation_method" {
  type        = string
  default     = "DNS"
  description = "Method to use for validation, DNS or EMAIL"
}

variable "certificate_transparency_logging_preference" {
  type        = bool
  default     = true
  description = "Specifies whether certificate details should be added to a certificate transparency log"
}

variable "zone_id" {
  type        = string
  default     = null
  description = "The zone id of the Route53 Hosted Zone which can be used instead of `var.zone_name`."
}

variable "zone_name" {
  type        = string
  default     = ""
  description = "The name of the desired Route53 Hosted Zone"
}

variable "wait_for_certificate_issued" {
  type        = bool
  default     = false
  description = "Whether to wait for the certificate to be issued by ACM (the certificate status changed from `Pending Validation` to `Issued`)"
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
