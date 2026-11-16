# Repository rulesets, keyed "<repository>/<name>", with no bypass actors. Each
# repository has one, "protect main", on its default branch: no deletion, no force
# push, and every change through a pull request. The pull request needs no
# approval, because the foundation has a single maintainer who merges their own
# pull requests. No status check is required: both repositories run their
# workflows only on the paths they cover, and a required check of a workflow that
# did not run stays pending and blocks the pull request.
variable "rulesets" {
  type = map(object({
    repository       = string
    name             = string
    target           = string
    enforcement      = string
    include          = list(string)
    exclude          = optional(list(string), [])
    deletion         = bool
    non_fast_forward = bool
    pull_request = optional(object({
      required_approving_review_count   = optional(number, 0)
      dismiss_stale_reviews_on_push     = optional(bool, false)
      require_code_owner_review         = optional(bool, false)
      require_last_push_approval        = optional(bool, false)
      required_review_thread_resolution = optional(bool, false)
    }))
  }))
  default = {
    "infrastructure/protect main" = {
      repository       = "infrastructure"
      name             = "protect main"
      target           = "branch"
      enforcement      = "active"
      include          = ["~DEFAULT_BRANCH"]
      deletion         = true
      non_fast_forward = true
      pull_request     = {}
    }
    "monorepo/protect main" = {
      repository       = "monorepo"
      name             = "protect main"
      target           = "branch"
      enforcement      = "active"
      include          = ["~DEFAULT_BRANCH"]
      deletion         = true
      non_fast_forward = true
      pull_request     = {}
    }
  }
}
