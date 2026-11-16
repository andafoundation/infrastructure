# Every repository of the account that this root manages, keyed by its name. Every
# setting the API returns is a row attribute, because one left out is planned as a
# clear. The values match what GitHub held when the repositories were imported, so
# the import changes nothing; a later change goes through its own pull request.
# A repository is retired by archived = true. Deleting a row fails the plan
# (prevent_destroy) unless the repository was first deleted in GitHub and its
# instances removed from state.
#
# actions_enabled is null on archived rows: an archived repository is read-only,
# so its Actions permissions get no resource. actions_allowed is set only where
# Actions are enabled, because GitHub keeps no allowed list for a disabled
# repository.
#
# dependabot_alerts and dependabot_security_updates default to true, so a new
# row gets both; security updates need the alerts on. Secret scanning and its
# push protection follow visibility, not a row: every public repository gets
# both (see the module).
variable "repositories" {
  type = map(object({
    description                 = optional(string)
    homepage_url                = optional(string)
    visibility                  = string
    archived                    = optional(bool, false)
    has_issues                  = bool
    has_projects                = bool
    has_wiki                    = bool
    allow_merge_commit          = bool
    allow_squash_merge          = bool
    allow_rebase_merge          = bool
    allow_auto_merge            = bool
    delete_branch_on_merge      = bool
    allow_update_branch         = bool
    squash_merge_commit_title   = string
    squash_merge_commit_message = string
    merge_commit_title          = string
    merge_commit_message        = string
    actions_enabled             = optional(bool)
    actions_allowed             = optional(string)
    dependabot_alerts           = optional(bool, true)
    dependabot_security_updates = optional(bool, true)
  }))
  default = {
    "infrastructure" = {
      description                 = "<INFRASTRUCTURE_DESCRIPTION>"
      visibility                  = "public"
      has_issues                  = true
      has_projects                = true
      has_wiki                    = true
      allow_merge_commit          = true
      allow_squash_merge          = true
      allow_rebase_merge          = true
      allow_auto_merge            = false
      delete_branch_on_merge      = false
      allow_update_branch         = false
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      squash_merge_commit_message = "COMMIT_MESSAGES"
      merge_commit_title          = "MERGE_MESSAGE"
      merge_commit_message        = "PR_TITLE"
      actions_enabled             = true
      actions_allowed             = "all"
    }
    "monorepo" = {
      description                 = "Core Monorepo for Anda Foundation. "
      visibility                  = "public"
      has_issues                  = true
      has_projects                = true
      has_wiki                    = true
      allow_merge_commit          = true
      allow_squash_merge          = true
      allow_rebase_merge          = true
      allow_auto_merge            = false
      delete_branch_on_merge      = false
      allow_update_branch         = false
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      squash_merge_commit_message = "COMMIT_MESSAGES"
      merge_commit_title          = "MERGE_MESSAGE"
      merge_commit_message        = "PR_TITLE"
      actions_enabled             = true
      actions_allowed             = "all"
    }
  }
}
