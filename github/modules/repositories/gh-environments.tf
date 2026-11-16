# Deployment environments, keyed "<repository>/<name>". A row with a branch lets
# only that branch deploy to the environment: protected_branches is off and the
# custom policy below names the branch, because a protected-branches policy would
# depend on rulesets the environment cannot see. A row without a branch keeps no
# policy, so every branch may use it; terraform-plan needs that, because pull
# request runs plan in it.
#
# Secret values are not here: a value in Terraform would be stored in state.
# They are set with gh secret set and survive an in-place update.
resource "github_repository_environment" "environments" {
  for_each    = var.environments
  repository  = github_repository.repos[each.value.repository].name
  environment = each.value.name

  dynamic "deployment_branch_policy" {
    for_each = each.value.branch == null ? [] : [each.value.branch]
    content {
      protected_branches     = false
      custom_branch_policies = true
    }
  }

  # Deleting an environment deletes its secrets and branch policies, and a new
  # repository or name replaces it. An environment is deleted in the UI first,
  # then its row.
  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_environment_deployment_policy" "branches" {
  for_each       = { for key, env in var.environments : key => env if env.branch != null }
  repository     = github_repository_environment.environments[each.key].repository
  environment    = github_repository_environment.environments[each.key].environment
  branch_pattern = each.value.branch
}

# One resource per environment variable, keyed "<repository>/<environment>/<name>".
# Variables are plain configuration that a workflow reads as vars.<name>; anything
# secret is an environment secret instead.
locals {
  environment_variables = merge([
    for key, env in var.environments : {
      for name, value in env.variables : "${key}/${name}" => {
        environment_key = key
        name            = name
        value           = value
      }
    }
  ]...)
}

resource "github_actions_environment_variable" "variables" {
  for_each      = local.environment_variables
  repository    = github_repository_environment.environments[each.value.environment_key].repository
  environment   = github_repository_environment.environments[each.value.environment_key].environment
  variable_name = each.value.name
  value         = each.value.value
}
