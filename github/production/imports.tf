# The repositories and their environments exist before this root: the repositories
# were created in GitHub, and the environments by hand so that the workflows had
# somewhere to read their secrets from. Without these blocks the apply would try to
# create each and fail on the conflict. The rows match what GitHub holds, so each
# import adopts the object unchanged. Rulesets, Actions permissions, Dependabot
# settings and environment variables are created; the Actions and Dependabot
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

# The branch policy "main" of an environment that deploys from main had to exist
# before this root, or no workflow on main could have used the environment. Its
# import id is "<repository>:<environment>:<policy id>", the numeric id GitHub gave
# the policy (see the README for the command that reads it).
locals {
  imported_branch_policy_ids = {
    "monorepo/production"            = "<MONOREPO_PRODUCTION_MAIN_POLICY_ID>"
    "infrastructure/terraform-apply" = "<INFRASTRUCTURE_TERRAFORM_APPLY_MAIN_POLICY_ID>"
  }
}

import {
  for_each = local.imported_branch_policy_ids
  to       = module.repositories.github_repository_environment_deployment_policy.branches[each.key]
  id       = "${replace(each.key, "/", ":")}:${each.value}"
}
