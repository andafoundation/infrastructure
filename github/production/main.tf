# Only the repositories module: the owner is a personal account, which has no
# organization settings, organization rulesets, teams or members to manage.
module "repositories" {
  source       = "../modules/repositories"
  repositories = var.repositories
  rulesets     = var.rulesets
  environments = var.environments
}
