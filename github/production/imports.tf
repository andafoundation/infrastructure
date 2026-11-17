# The repositories and their environments exist before this root: the repositories
# were created in GitHub, and the environments by hand so that the workflows had
# somewhere to read their secrets from. Without these blocks the apply would try to
# create each and fail on the conflict. Each import adopts the object, and a row
# that differs from GitHub shows as an in-place update in the plan. Rulesets,
# Actions permissions, Dependabot settings, the "main" branch policies of the
# environments limited to main and the environment variables are created; no
# environment had a branch policy before this root. The Actions and Dependabot
# resources only set a switch, so creating them for a repository that already has
# the setting changes nothing in GitHub.
#
# Once applied, the imports are no-ops: Terraform skips an import whose address is
# already in state.

import {
  for_each = toset(["infrastructure", "monorepo"])
  to       = module.repositories.github_repository.repos[each.key]
  id       = each.key
}

# Import id "<repository>:<environment>".
import {
  for_each = toset(["monorepo/production", "infrastructure/terraform-plan", "infrastructure/terraform-apply"])
  to       = module.repositories.github_repository_environment.environments[each.key]
  id       = replace(each.key, "/", ":")
}
