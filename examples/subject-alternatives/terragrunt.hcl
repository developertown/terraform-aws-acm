include {
  path = find_in_parent_folders()
}

dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_id     = "Z00000000000000000000"
    domain_name = "some.domain.com"
  }
}

terraform {
  source = "../..//"
}

inputs = {
  region                    = "us-east-1"
  dns_name                  = dependency.dns.outputs.domain_name
  subject_alternative_names = ["subdomain.${dependency.dns.outputs.domain_name}"]
  dns_zone_id               = dependency.dns.outputs.zone_id
}
