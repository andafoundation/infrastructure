# One ruleset per row, keyed "<repository>/<name>". The repository must be a row
# of var.repositories, so a typo fails the plan instead of creating a ruleset on
# nothing. No bypass actors: a ruleset that blocks deleting the default branch,
# rewriting its history or pushing to it directly has no caller that should be
# allowed to skip it, the owner and this root's own token included.
resource "github_repository_ruleset" "rulesets" {
  for_each    = var.rulesets
  repository  = github_repository.repos[each.value.repository].name
  name        = each.value.name
  target      = each.value.target
  enforcement = each.value.enforcement

  conditions {
    ref_name {
      include = each.value.include
      exclude = each.value.exclude
    }
  }

  rules {
    deletion         = each.value.deletion
    non_fast_forward = each.value.non_fast_forward

    # Present only on a row that sets pull_request: a row without it keeps no
    # pull_request block, so the rule is never sent half-filled.
    dynamic "pull_request" {
      for_each = each.value.pull_request == null ? [] : [each.value.pull_request]
      content {
        required_approving_review_count   = pull_request.value.required_approving_review_count
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
      }
    }
  }

  # Deleting a ruleset lifts the protection it holds. A ruleset is deleted in the
  # UI first, then its row.
  lifecycle {
    prevent_destroy = true
  }
}
