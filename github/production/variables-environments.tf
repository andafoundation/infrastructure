# Deployment environments, keyed "<repository>/<name>". branch names the only
# branch that may deploy to the environment; null leaves it open to every branch.
# variables are environment variables a workflow reads as vars.<name>. Secrets
# are never rows: they are set with gh secret set (see the README).
#
# monorepo/production is where the website deploys from main. terraform-plan has
# no branch, because pull request runs plan in it with read-only tokens.
# terraform-apply holds the write tokens and is limited to main.
variable "environments" {
  type = map(object({
    repository = string
    name       = string
    branch     = optional(string)
    variables  = optional(map(string), {})
  }))
  default = {
    "monorepo/production" = {
      repository = "monorepo"
      name       = "production"
      branch     = "main"
      variables = {
        CLOUDFLARE_ACCOUNT_ID = "71d62ebb4223320c37383e3398f86a59"
      }
    }
    "infrastructure/terraform-plan" = {
      repository = "infrastructure"
      name       = "terraform-plan"
    }
    "infrastructure/terraform-apply" = {
      repository = "infrastructure"
      name       = "terraform-apply"
      branch     = "main"
    }
  }
}
