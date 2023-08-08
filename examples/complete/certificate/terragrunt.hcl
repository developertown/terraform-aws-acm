include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//."
}

inputs = {
  enabled = true

  region      = "us-east-2"
  environment = "test"

  domain_name                       = "test.clientdomains.co"
  subject_alternative_names         = ["*.test.clientdomains.co"]
  zone_id                           = "Z077885132H950566GBOD"
  validation_method                 = "DNS"
  ttl                               = "300"
  process_domain_validation_options = true
  wait_for_certificate_issued       = false

  tags = {
    "Company" = "DeveloperTown"
  }
}
