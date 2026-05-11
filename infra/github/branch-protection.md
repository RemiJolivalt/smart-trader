# Branch protection rules — Smart Trader

> À configurer manuellement sur GitHub (Settings → Branches → Add rule).

## Branche `main`

- ✅ **Require a pull request before merging**
  - Required approvals: **1** (passer à 2 dès qu'un 2e contributeur)
  - Dismiss stale approvals on new commits
  - Require review from **Code Owners**
- ✅ **Require status checks to pass before merging**
  - Strict (branches up to date)
  - Required checks:
    - `frontend`
    - `backend`
    - `security`
    - `ci-status`
- ✅ **Require conversation resolution before merging**
- ✅ **Require signed commits** (recommandé)
- ✅ **Require linear history**
- ✅ **Do not allow bypassing the above settings**
- ❌ **Allow force pushes** (interdit)
- ❌ **Allow deletions** (interdit)

## Branche `develop`

- ✅ Require PR (1 approval)
- ✅ Required status checks (mêmes que `main`)
- ✅ Require conversation resolution
- ❌ Force pushes / deletions interdits

## Tags

- ✅ Protected tags : `v*`
