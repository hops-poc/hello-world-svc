# dev stack — thin caller of paved-road's service module. State lives at
# dev/terraform.tfstate in the shared bucket (bootstrap/).
#
# Module source is pinned to the commit deploy.yml itself runs from — bump
# this alongside ci.yml's workflow-call SHA, not independently.

terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hops-poc-paved-road-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "paved-road-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  # `tofu validate` calls the provider's Configure(), which pings STS even
  # for validate (no plan/apply happens) — confirmed empirically: with zero
  # AWS credentials it errors on IMDS, and with dummy credentials it still
  # calls GetCallerIdentity and gets a real 403. CI's credential-less
  # tofu-validate job (paved-road plan.yml) needs both of these to run
  # offline; real deploys still authenticate normally via OIDC-assumed
  # role credentials for every actual resource call, this only skips one
  # eager sanity ping. Module doesn't read the account ID anywhere, so
  # skip_requesting_account_id is free.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

variable "image_uri" {
  description = "Digest-pinned ECR image built from this commit (repo@sha256:...)"
  type        = string
}

module "service" {
  source    = "git::https://github.com/hops-poc/paved-road.git//modules/service?ref=b3e87542d07f974e1883190ab3a2d5cba0ad9acd"
  env       = "dev"
  image_uri = var.image_uri
}

output "url" {
  value = module.service.url
}

output "function_url" {
  value = module.service.function_url
}
