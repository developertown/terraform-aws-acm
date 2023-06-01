include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-route53.git?ref=main"
}

inputs = {
  region   = "us-east-1"
  dns_name = "somedomain.com"
}
