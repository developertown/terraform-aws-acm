# terraform-aws-acm

## Usage

### Basic

Create a DNS Validated ACM Certificate in the Authenticated AWS Account. Assumes both the Certificate and Route 53 Zone are managed by the same AWS Account.

<details open>
  <summary>Terragrunt</summary>

```hcl
dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_id     = "Z00000000000000000000"
    domain_name = "some.domain.com"
  }
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-acm.git?ref=VERSION"
}

inputs = {
  region      = "us-east-1"
  dns_name    = dependency.dns.outputs.domain_name
  dns_zone_id = dependency.dns.outputs.zone_id
}
```

</details>

<details>
  <summary>Terraform</summary>

```hcl
module "dns" {
  source  = "github.com/developertown/terraform-aws-route53.git"
  version = "VERSION"
}

module "cert" {
  source  = "github.com/developertown/terraform-aws-acm.git"
  version = "VERSION"

  region      = "us-east-1"
  dns_name    = module.dns.domain_name
  dns_zone_id = dependency.dns.zone_id
}
```

</details>

### Assume Role

Create a DNS Validated ACM Certificate by Assuming Role into another AWS Account. Optionally use parent_role_arn if the parent_dns_zone_id requires an assumed role to be accessible.

<details open>
  <summary>Terragrunt</summary>

```hcl
dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_id     = "Z00000000000000000000"
    domain_name = "some.domain.com"
  }
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-acm.git?ref=VERSION"
}

inputs = {
  region      = "us-east-1"
  role_arn    = "arn:aws:iam::XXXXXXXXXXXX:role/SomeRole"
  dns_name    = dependency.dns.outputs.domain_name
  dns_zone_id = dependency.dns.outputs.zone_id
  #parent_dns_zone_id               = "Z00000000000000000001"
  #parent_role_arn                 = "arn:aws:iam::XXXXXXXXXXXX:role/SomeOtherRole"
}
```

</details>

<details>
  <summary>Terraform</summary>

```hcl
module "dns" {
  source  = "github.com/developertown/terraform-aws-route53.git"
  version = "VERSION"
}

module "cert" {
  source  = "github.com/developertown/terraform-aws-acm.git"
  version = "VERSION"

  region      = "us-east-1"
  role_arn    = "arn:aws:iam::XXXXXXXXXXXX:role/SomeRole"
  dns_name    = module.dns.domain_name
  dns_zone_id = dependency.dns.zone_id
  #parent_dns_zone_id               = "Z00000000000000000001"
  #parent_role_arn                 = "arn:aws:iam::XXXXXXXXXXXX:role/SomeOtherRole"
}
```

</details>

### Subject Alternatives

Create a DNS Validated ACM Certificate with Subject Alternatives in the Authenticated AWS Account. Assumes both the Certificate and Route 53 Zone are managed by the same AWS Account.

<details open>
  <summary>Terragrunt</summary>

```hcl
dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_id     = "Z00000000000000000000"
    domain_name = "some.domain.com"
  }
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-acm.git?ref=VERSION"
}

inputs = {
  region      = "us-east-1"
  dns_name    = dependency.dns.outputs.domain_name
  subject_alternative_names = ["subdomain.${dependency.dns.outputs.domain_name}"]
  dns_zone_id = dependency.dns.outputs.zone_id
}
```

</details>

<details>
  <summary>Terraform</summary>

```hcl
module "dns" {
  source  = "github.com/developertown/terraform-aws-route53.git"
  version = "VERSION"
}

module "cert" {
  source  = "github.com/developertown/terraform-aws-acm.git"
  version = "VERSION"

  region      = "us-east-1"
  dns_name    = module.dns.domain_name
  subject_alternative_names = ["subdomain.${module.dns.domain_name}"]
  dns_zone_id = dependency.dns.zone_id
}
```

</details>

### Parent Zone Subject Alternatives

Create a DNS Validated ACM Certificate with Subject Alternatives in the Authenticated AWS Account. Assumes both the Certificate are managed by one AWS account and Route 53 Zone required to validate the Subject alternatives exist in a different AWS Account.

<details open>
  <summary>Terragrunt</summary>

```hcl
dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_id     = "Z00000000000000000000"
    domain_name = "some.domain.com"
  }
}

terraform {
  source = "git::https://github.com/developertown/terraform-aws-acm.git?ref=VERSION"
}

inputs = {
  region      = "us-east-1"
  dns_name    = dependency.dns.outputs.domain_name
  parent_dns_zone_id               = "Z00000000000000000001"
  parent_subject_alternative_names = ["domain.com"]
  #parent_role_arn                 = "arn:aws:iam::XXXXXXXXXXXX:role/SomeOtherRole"
}
```

</details>

<details>
  <summary>Terraform</summary>

```hcl
module "dns" {
  source  = "github.com/developertown/terraform-aws-route53.git"
  version = "VERSION"
}

module "cert" {
  source  = "github.com/developertown/terraform-aws-acm.git"
  version = "VERSION"

  region      = "us-east-1"
  dns_name    = module.dns.domain_name
  dns_zone_id = dependency.dns.zone_id
  parent_dns_zone_id               = "Z00000000000000000001"
  parent_subject_alternative_names = ["domain.com"]
  #parent_role_arn                 = "arn:aws:iam::XXXXXXXXXXXX:role/SomeOtherRole"

}
```

</details>

## Providers

| Name            | Version     |
| --------------- | ----------- |
| `hashicorp/aws` | `~> 4.36.1` |

## Inputs

| Input                            | Description                                                                                                                                                                                             | Default | Required |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| region                           | AWS Region to create resources in                                                                                                                                                                       | N/A     | Yes      |
| tags                             | A set of key/value label pairs to assign to this to the resources                                                                                                                                       | `{}`    | No       |
| role_arn                         | The AWS assume role                                                                                                                                                                                     | `""`    | No       |
| dns_name                         | The domain name for which the certificate should be issued. A certificate and a Route53 DNS validation record will be created in the aws account granted by `role_arn`                                  | N/A     | Yes      |
| subject_alternative_names        | Set of domains that should be SANs in the issued certificate. A Route53 DNS validation record will be created for each subject_alternative_names in the aws account granted by `role_arn`               | `[]`    | No       |
| dns_zone_id                      | The ID of the Route53 hosted zone to contain the Certificate validation record for the `dns_name` and `subject_alternative_names`. The Route53 hosted zone must be accessible via the `role_arn`        | `""`    | Yes      |
| dns_ttl                          | The TTL to use for SSL certificates, and Route 53 records                                                                                                                                               | `60`    | No       |
| parent_subject_alternative_names | Set of domains that should be SANs in the issued certificate. A Route53 DNS validation record will be created for each parent_subject_alternative_names in the aws account granted by `parent_role_arn` | `[]`    | No       |
| parent_dns_zone_id               | The ID of the Route53 hosted zone to contain the Certificate validation record for the `parent_subject_alternative_names`. The Route53 hosted zone must be accessible via the `parent_role_arn`         | `""`    | No       |
| parent_role_arn                  | The AWS assume role                                                                                                                                                                                     | `""`    | No       |
| sns_alarm_topic_arn              | The SNS Topic ARN to use for Cloudwatch Alarms                                                                                                                                                          | `""`    | No       |
| alarm_expiration_threshold       | Number of days before certificate expiration to trigger an alarm                                                                                                                                        | `14`    | No       |

## Outputs

| Output          | Description                |
| --------------- | -------------------------- |
| certificate_arn | The ARN of the certificate |
