terraform {
  # 1.10 is the first version with use_lockfile on the s3 backend; CI pins the exact
  # version in .github/workflows/terraform.yml.
  required_version = ">= 1.10.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13.0"
    }
  }

  # Same R2 bucket and settings as the cloudflare root, with a key of its own: the
  # GitHub state is a separate lineage with its own lock object, so an apply of one
  # root never holds or overwrites the other's state. A backend block cannot read
  # variables, so the account id is written into the endpoint. Credentials come only
  # from AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, which the workflow maps from
  # the R2 secrets of its environment.
  backend "s3" {
    bucket = "anda-terraform-state"
    key    = "github-production.tfstate"
    region = "auto"
    endpoints = {
      s3 = "https://<ANDA_ACCOUNT_ID>.r2.cloudflarestorage.com"
    }

    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# The token is deliberately absent. The provider reads GITHUB_TOKEN from the
# environment, which the workflow fills from the TF_GITHUB_TOKEN secret: a
# read-only fine-grained token in the plan job, a read and write one in the apply
# job. The owner is a personal account, so the provider manages its repositories
# without any organization call. Without GITHUB_TOKEN the provider falls back to
# the gh login, which is enough for terraform validate.
provider "github" {
  owner = var.github_owner
}
