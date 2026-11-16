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

Both workflows call the reusable `.github/workflows/terraform.yml`. The roots and workflows are
added by the first pull requests after this initial commit.

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
`gh secret set <NAME> -e <environment> -R andafoundation/infrastructure`. None has a value in
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

Values the owner fills in when the roots are added:

| Value | Where it goes |
|---|---|
| `<anda-account-id>` | default of `cloudflare_account_id` in the cloudflare root; R2 endpoint `https://<anda-account-id>.r2.cloudflarestorage.com` in both backends |
| `<andaphilosophy.com zone id>`, `<andaism.com zone id>` | the `import` blocks that adopt the two zones |

## Not managed by Terraform

These are set by hand in the GitHub or Cloudflare settings:

- the zones themselves (no API token can create a zone; they are added in the dashboard and then
  imported);
- secret values and the tokens behind them;
- private vulnerability reporting on both repositories;
- Actions: "Require approval for all outside collaborators" on fork pull requests;
- the nameservers and DNSSEC at the domain registrar.

## Bootstrap

This repository was empty, so its first commit (this README, `.gitignore` and `LICENSE`) is pushed
to `main` directly. Until the github root applies the `protect main` ruleset, every later change
still goes through a pull request by hand. The apply token can change the protection of this
repository; a pull request that weakens it shows that in its plan.

## Licence

[Apache License 2.0](LICENSE).
