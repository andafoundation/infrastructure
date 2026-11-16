# Dependabot alerts and security updates per repository, from the row flags
# dependabot_alerts and dependabot_security_updates. Archived rows get neither:
# an archived repository is read-only and the provider refuses both writes.
#
# The alerts use their own resource, not the vulnerability_alerts argument of
# github_repository, which provider 6.13.0 deprecates. Both resources only PUT
# or DELETE the setting, so creating one for a repository that already has the
# setting changes nothing in GitHub. A destroy turns the setting off.
resource "github_repository_vulnerability_alerts" "repos" {
  for_each   = { for name, repo in var.repositories : name => repo if !repo.archived }
  repository = github_repository.repos[each.key].name
  enabled    = each.value.dependabot_alerts
}

# GitHub accepts security updates only on a repository whose alerts are on, so
# the repository is read from the alerts resource: that orders the alerts first.
resource "github_repository_dependabot_security_updates" "repos" {
  for_each   = { for name, repo in var.repositories : name => repo if !repo.archived }
  repository = github_repository_vulnerability_alerts.repos[each.key].repository
  enabled    = each.value.dependabot_security_updates
}
