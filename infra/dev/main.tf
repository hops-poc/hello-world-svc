# dev stack — thin caller of paved-road's service module. State lives at
# dev/terraform.tfstate in the shared bucket (bootstrap/).
#
# Module source is a local relative path for session-2 manual apply; session 3's
# deploy.yml swaps it for a pinned git ref
# (git::https://github.com/hops-poc/paved-road.git//modules/service?ref=<sha>).

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
}

variable "image_uri" {
  description = "Digest-pinned ECR image built from this commit (repo@sha256:...)"
  type        = string
}

module "service" {
  source    = "../../../paved-road/modules/service"
  env       = "dev"
  image_uri = var.image_uri
}

output "url" {
  value = module.service.url
}

output "function_url" {
  value = module.service.function_url
}
