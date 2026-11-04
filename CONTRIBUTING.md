# Contributing to SmartProcure

Nobody pushes directly to `main` or `develop`. **Every change goes through a pull request.** This is enforced by repository rulesets, not by good intentions.

## Branches

| Branch | Purpose | Who changes it |
|---|---|---|
| `main` | production-ready, tagged releases (`v1.0.0`) | release pull request from `develop` only |
| `develop` | integration branch | feature pull requests only |
| `feature/us-NN-<name>` | one user story | you; created from `develop`, deleted after merge |
| `fix/<name>`, `chore/<name>`, `docs/<name>` | bug fix, maintenance, documentation | you |
| `hotfix/<name>` | urgent production fix, created from `main` | you, then merged back into `develop` |

## Workflow

1. Create or pick an issue (user-story template). Agree the acceptance criteria.
2. `git switch develop && git pull && git switch -c feature/us-NN-<name>`
3. Commit in small steps with [Conventional Commits](https://www.conventionalcommits.org): `feat(US-03): approve with comment`, `fix: ...`, `test: ...`, `docs: ...`.
4. Push the branch and open a pull request **into `develop`**. Fill the PR template.
5. CI (`ci`) must be green. Another person reviews. Answer every review thread; push fixes to the same branch.
6. Squash-and-merge. The branch is deleted automatically.
7. Release: open a pull request `develop` → `main` (**merge commit**, not squash), then tag `vX.Y.Z`.

## What the rules enforce (rulesets on `main` and `develop`)

- pull request required; **1 approving review** from a code owner (`.github/CODEOWNERS`)
- approval is dismissed when new commits are pushed; the last pusher cannot be the only approver
- all review conversations resolved before merge
- required status check `ci`, and the branch must be up to date with its base
- force pushes and branch deletion blocked; release tags `v*` cannot be moved or deleted
- merge methods: squash (features) and merge commit (releases); rebase merging is disabled
- secret scanning with push protection, Dependabot alerts and security updates

The repository admin role can merge a pull request without the required approval when no second reviewer is available
(a solo-maintainer situation). Direct pushes stay blocked for everyone. Remove that bypass in
*Settings → Rules → Rulesets → protect-main-and-develop* once a second reviewer is active.

## Reviewer checklist

- [ ] The PR does one thing and the description says why
- [ ] Tests were added or changed; CI is green
- [ ] No files of another owner changed without telling them
- [ ] Authorization (`@requires` / `@restrict`) present on every new action or function
- [ ] No secrets, personal data or debug leftovers
- [ ] Database/contract changes are called out and documented

## Local checks

```bash
npm ci
npm test --if-present
npx cds compile '*' --to json > /dev/null   # the model must compile
```
