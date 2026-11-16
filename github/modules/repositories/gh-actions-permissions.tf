# Only rows that set actions_enabled get a resource: an archived repository is
# read-only, so its Actions permissions cannot be managed. allowed_actions stays
# null on a row with Actions disabled, because GitHub accepts no allowed list
# there. No prevent_destroy: a destroy only returns the repository to the
# account's defaults, and no data is lost.
resource "github_actions_repository_permissions" "repos" {
  for_each        = { for name, repo in var.repositories : name => repo if repo.actions_enabled != null }
  repository      = github_repository.repos[each.key].name
  enabled         = each.value.actions_enabled
  allowed_actions = each.value.actions_allowed
}
