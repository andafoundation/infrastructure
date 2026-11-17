terraform {
  # 1.10 is the first version with use_lockfile on the s3 backend; CI pins the exact
  # version in .github/workflows/terraform.yml.
  required_version = ">= 1.10.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.27.0"
    }
  }

  # State lives in the R2 bucket anda-terraform-state of the Anda Cloudflare account,
  # through R2's S3-compatible API. A backend block cannot read variables, so the
  # account id is written into the endpoint. Credentials come only from
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, which the workflow maps from the R2
  # secrets of its environment. use_lockfile writes a lock object next to the state,
  # so a second apply of this root waits instead of overwriting it. The skip_* flags
  # turn off the AWS-only checks R2 does not answer.
  backend "s3" {
    bucket = "anda-terraform-state"
    key    = "cloudflare-production.tfstate"
    region = "auto"
    endpoints = {
      s3 = "https://71d62ebb4223320c37383e3398f86a59.r2.cloudflarestorage.com"
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

# The API token is deliberately absent. The provider reads CLOUDFLARE_API_TOKEN,
# which the workflow exports from a read-only token in the plan job and from an
# edit token in the apply job.
provider "cloudflare" {}
