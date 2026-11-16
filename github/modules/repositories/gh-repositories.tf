# One repository per row, keyed by its name. Every setting is set from the row,
# because an argument left out is planned as a clear of what GitHub holds today.
# Discussions, pages and topics are not rows: none is in use. Dependabot alerts
# and security updates have resources of their own in gh-dependabot.tf.
# security_and_analysis is optional and computed, so a repository without the
# block keeps what GitHub holds and the provider sends nothing for it.
resource "github_repository" "repos" {
  for_each     = var.repositories
  name         = each.key
  description  = each.value.description
  homepage_url = each.value.homepage_url
  visibility   = each.value.visibility
  archived     = each.value.archived

  has_issues   = each.value.has_issues
  has_projects = each.value.has_projects
  has_wiki     = each.value.has_wiki

  allow_merge_commit          = each.value.allow_merge_commit
  allow_squash_merge          = each.value.allow_squash_merge
  allow_rebase_merge          = each.value.allow_rebase_merge
  allow_auto_merge            = each.value.allow_auto_merge
  allow_update_branch         = each.value.allow_update_branch
  delete_branch_on_merge      = each.value.delete_branch_on_merge
  squash_merge_commit_title   = each.value.squash_merge_commit_title
  squash_merge_commit_message = each.value.squash_merge_commit_message
  merge_commit_title          = each.value.merge_commit_title
  merge_commit_message        = each.value.merge_commit_message

  # Secret scanning and its push protection on every public repository, where
  # GitHub offers them free: a public repository's history is readable by anyone,
  # so a pushed credential leaks at once. A private repository gets no block,
  # because GitHub refuses both settings there without a paid licence.
  # advanced_security is left out: on a public repository it is always on and
  # cannot be supplied.
  dynamic "security_and_analysis" {
    for_each = each.value.visibility == "public" ? [each.key] : []
    content {
      secret_scanning {
        status = "enabled"
      }
      secret_scanning_push_protection {
        status = "enabled"
      }
    }
  }

  # Deleting a repository loses its code, issues and pull requests. prevent_destroy
  # refuses the plan; should the lifecycle block ever go, the provider archives
  # instead of deleting. A repository is retired by archived = true, and deleted in
  # the UI before its row is removed.
  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}
