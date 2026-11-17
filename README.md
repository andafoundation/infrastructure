# Anda infrastructure

Terraform for the infrastructure of the Anda Foundation (Stichting Anda): the Cloudflare zones of
`andaphilosophy.com` and `andaism.com`, and the settings of the GitHub repositories
`andafoundation/monorepo` and `andafoundation/infrastructure`. The website itself lives in
[`andafoundation/monorepo`](https://github.com/andafoundation/monorepo) and deploys as a
Cloudflare Worker from that repository.

**Everything here is applied by GitHub Actions, never from a laptop.**

Two Terraform roots, one per provider, each with its own state key and workflow:

| Root | Manages | State key | Workflow |
|---|---|---|---|
| `cloudflare/production/` (modules in `cloudflare/modules/`) | the two zones, their DNS records (one `records-<zone>.tf` per zone), the `ssl` and `always_use_https` settings, the redirect from `andaism.com` to `andaphilosophy.com` and from `www.andaphilosophy.com` to `andaphilosophy.com` | `cloudflare-production.tfstate` | `.github/workflows/cloudflare-terraform.yml` |
| `github/production/` (modules in `github/modules/`) | both repositories (secret scanning and push protection included), their `protect main` rulesets, Actions permissions, Dependabot settings, the environments with their branch policies and variables | `github-production.tfstate` | `.github/workflows/github-terraform.yml` |

Both workflows call the reusable `.github/workflows/terraform.yml`, whose jobs are written out in
this repository with public actions pinned by commit SHA.

The cloudflare root adopts the two zones with `cloudflare/production/import-zones.tf` (a zone can
only be added in the dashboard) and creates everything else: records, settings and the redirect
rulesets. Delete the records the dashboard scan added to a new zone before the first apply.

The github root manages a personal account, so it has no organization, team or member settings.
`github/production/imports.tf` adopts what existed before it: both repositories, the three
environments (`monorepo/production`, `infrastructure/terraform-plan`,
`infrastructure/terraform-apply`). Where a row differs from what GitHub holds, the plan of its
import shows an in-place update: the first plan sets the description and public visibility of this
repository and turns on custom branch policies for the two environments limited to `main`. The
plan also creates the two `protect main` rulesets, the Actions permissions, the Dependabot
switches, the `main` branch policies of the two environments limited to `main` and the environment
variable `CLOUDFLARE_ACCOUNT_ID` of `monorepo/production`.

## The loop

1. Branch, change a root, open a pull request.
2. CI runs `terraform fmt -check`, `init -backend=false` and `validate` (job `check`), then
   `plan` in the environment `terraform-plan` and writes it to the job summary.
3. Read the plan, then merge.
4. The push to `main` runs a fresh `plan`, applies it in the environment `terraform-apply`, and
   plans once more: the run fails if that last plan still finds a change.

| Trigger | What runs |
|---|---|
| Pull request from a branch of this repository | `check`, then `plan` (read-only tokens) |
| Pull request from a fork | `check` only; fork code never reaches a token |
| Pull request from Dependabot | `check` only; the merge plans and applies |
| Push to `main` touching a root | `check`, then `apply` (write tokens) |

No plan is uploaded as an artifact: artifacts of a public repository can be downloaded by anyone,
and a plan holds a copy of state.

## State

One R2 bucket, `anda-terraform-state`, in the Anda Cloudflare account, through the `s3` backend
with `use_lockfile = true`. A second plan or apply on the same root waits for the lock file.
Credentials come only from `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, which the workflows map
from the secrets below. Terraform `1.16.5`; providers `cloudflare/cloudflare ~> 5.27.0` and
`integrations/github ~> 6.13.0`. Commit `.terraform.lock.hcl`; it pins the provider checksums.

## Credentials

Every secret is an environment secret of this repository, set with
`gh secret set <name> -e <environment> -R andafoundation/infrastructure`. None has a value in
Terraform or in this repository.

| Secret | Environment | Rights |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | `terraform-plan` | Zone, DNS, Zone Settings, Single Redirect: Read, on the two zones |
| `CLOUDFLARE_API_TOKEN` | `terraform-apply` | the same, Edit (Zone stays Read) |
| `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` | both | R2 Object Read and Write, bucket `anda-terraform-state` only |
| `TF_GITHUB_TOKEN` | `terraform-plan` | fine-grained token of `andafoundation`, repositories `monorepo` and `infrastructure` only: Administration, Environments, Variables, Metadata: Read |
| `TF_GITHUB_TOKEN` | `terraform-apply` | the same repositories: Administration, Environments, Variables: Read and write; Metadata: Read |

`TF_GITHUB_TOKEN` is mapped to `GITHUB_TOKEN` in the github root's jobs only (a secret name cannot
start with `GITHUB_`). The tokens do not expire. To rotate one, roll it in the Cloudflare or
GitHub settings and set the new value with the `gh secret set` command above.

## Values to check

Before the first github plan, compare the two rows of `github/production/variables-repositories.tf`
with what GitHub holds, signed in as `andafoundation`, and correct a row where it differs:
`gh api repos/andafoundation/<repository> --jq '{description, homepage, visibility, has_issues, has_projects, has_wiki, allow_merge_commit, allow_squash_merge, allow_rebase_merge, allow_auto_merge, delete_branch_on_merge, allow_update_branch, squash_merge_commit_title, squash_merge_commit_message, merge_commit_title, merge_commit_message}'`.
The merge settings in the rows are GitHub's defaults for a new repository; only an administrator
of the repository can read the real values. A row that differs shows as an in-place update in the
plan of an import.

These must match what the owner creates:

- the R2 bucket is named `anda-terraform-state` (`bucket` in `cloudflare/production/provider.tf`);
- the GitHub environments are named `terraform-plan` and `terraform-apply`, and each holds the
  secrets `CLOUDFLARE_API_TOKEN`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` and
  `TF_GITHUB_TOKEN` of the table above;
- the environments exist before the first github plan, with no reviewers and no wait timer.
  Created by hand, that is `gh api -X PUT repos/andafoundation/<repository>/environments/<environment>`.
  The apply then sets them as their rows in `github/production/variables-environments.tf` say:
  `terraform-plan` open to every branch, `terraform-apply` (and `production` of
  `andafoundation/monorepo`) limited to `main` by a custom branch policy that the apply creates.

An account id and a zone id are identifiers, not credentials; they may be committed.

## Not managed by Terraform

These are set by hand in the GitHub or Cloudflare settings:

- the zones themselves (no API token can create a zone; they are added in the dashboard and then
  imported);
- secret values and the tokens behind them;
- private vulnerability reporting on both repositories;
- on both repositories, the security settings that provider `integrations/github` 6.13.0 cannot
  manage, set through the API as `andafoundation`. The provider neither sends nor reads them, so
  they cause no change in a plan:
  - secret scanning of non-provider patterns and secret scanning validity checks:
    `gh api -X PATCH repos/andafoundation/<repository> --input -` with
    `{"security_and_analysis": {"secret_scanning_non_provider_patterns": {"status": "enabled"}, "secret_scanning_validity_checks": {"status": "enabled"}}}`;
  - code scanning with CodeQL default setup, which picks the languages itself (Actions here,
    Actions and JavaScript/TypeScript in `andafoundation/monorepo`):
    `gh api -X PATCH repos/andafoundation/<repository>/code-scanning/default-setup -f state=configured`;
- Actions: "Require approval for all outside collaborators" on fork pull requests;
- the nameservers and DNSSEC at the domain registrar.
- the Worker and its custom domain `andaphilosophy.com`, deployed from `andafoundation/monorepo`,
  with the read-only AAAA record that the custom domain creates.

## Bootstrap

This repository was empty, so its first commit (this README, `.gitignore` and `LICENSE`) is pushed
to `main` directly. Until the github root applies the `protect main` rulesets, every later change
still goes through a pull request by hand. The rulesets require a pull request with no approval
(the foundation has one maintainer) and no status check: the workflows run only on the paths they
cover, and a required check of a workflow that did not run would stay pending. The apply token
can change the protection of this repository; a pull request that weakens it shows that in its
plan.

## Licence

[Apache License 2.0](LICENSE).
