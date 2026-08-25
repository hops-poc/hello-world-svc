# prod stack — same module as dev, prod-named resources, its own state file.
# The same image digest dev ran is promoted here (§5.3). Module source note:
# see infra/dev/main.tf.

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
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "paved-road-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "image_uri" {
  description = "Digest-pinned ECR image promoted from dev (repo@sha256:...)"
  type        = string
}

module "service" {
  source    = "../../../paved-road/modules/service"
  env       = "prod"
  image_uri = var.image_uri
}

output "url" {
  value = module.service.url
}

output "function_url" {
  value = module.service.function_url
}
