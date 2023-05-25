# terraform-{provider}-{name}

## Usage

### Basic

<details open>
  <summary>Terragrunt</summary>

```hcl
terraform {
  source = "git::https://github.com/developertown/terraform-{provider}-{name}.git?ref=vVERSION"
}

inputs = {
}
```

</details>

<details>
  <summary>Terraform</summary>

```hcl
module "apex_zone" {
  source  = "github.com/developertown/terraform-{provider}-{name}.git"
  version = "VERSION"

}
```

</details>

## Providers

| Name | Version |
| ---- | ------- |

## Inputs

| Input | Description | Default | Required |
| ----- | ----------- | ------- | -------- |

## Outputs

| Output | Description |
| ------ | ----------- |
