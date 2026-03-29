# Integration Scenarios: Action Version Drift Detection

## Setup

- `.github/actions-versions.yml` exists with entries for all 12 actions currently
  used across `.github/workflows/`.
- `.specify/scripts/bash/check-action-versions.sh` is executable.
- `ci-action-version-drift.yml` is active and triggers on `pull_request` paths `.github/**`.

---

## Scenario 1: Aligned State (Baseline)

**Given** all workflow `uses:` references match the versions in the manifest.
**When** the drift check runs locally:
  ```
  bash .specify/scripts/bash/check-action-versions.sh --strict
  ```
**Then** it exits `0` and prints:
  ```
  ✓ All action versions aligned with manifest.
  ```

---

## Scenario 2: Dependabot PR — Workflow Files Updated, Manifest Not Yet

**Given** Dependabot opens a grouped PR that bumps `actions/checkout` from `v6` to `v7`
  in all workflow files.
**And** `.github/actions-versions.yml` still records `actions/checkout: version: v6`.
**When** the CI drift check runs on the PR.
**Then** the job fails and the step summary reports:
  ```
  DRIFT DETECTED: N mismatch(es) found

    [MISMATCH] .github/workflows/backend-docker-build.yml:53
               actions/checkout — found: v7, expected: v6
    ...
  ```
**And** the PR cannot be merged until the drift is resolved.

---

## Scenario 3: Dependabot PR — Manifest Updated (Resolved)

**Given** Scenario 2 above.
**When** the maintainer updates `.github/actions-versions.yml` to set
  `version: v7` for `actions/checkout` and pushes to the PR branch.
**Then** the CI drift check passes with exit `0`.
**And** the step summary shows:
  ```
  ✅ All action versions aligned with .github/actions-versions.yml
  ```
**And** the PR is unblocked and can be merged.

---

## Scenario 4: New Workflow Added with Unregistered Action

**Given** a contributor adds `.github/workflows/ci-new-tool.yml` containing:
  ```yaml
  - uses: some/new-action@v3
  ```
**And** `some/new-action` has no entry in `.github/actions-versions.yml`.
**When** the CI drift check runs with `--strict` (default in CI).
**Then** the job fails and reports:
  ```
  UNREGISTERED ACTIONS: 1 action(s) not in manifest

    [UNREGISTERED] .github/workflows/ci-new-tool.yml:12
                   some/new-action@v3 — not in .github/actions-versions.yml
  ```
**And** the contributor must add `some/new-action` to the manifest before the PR can merge.

---

## Scenario 5: Local Workflow Reference Not Flagged

**Given** a workflow file contains:
  ```yaml
  uses: ./.github/workflows/reusable-build.yml
  ```
**When** the drift check runs.
**Then** this reference is silently skipped — no mismatch or unregistered report.

---

## Scenario 6: Manual Dispatch (No PR)

**Given** the CI workflow is triggered via `workflow_dispatch` on the default branch.
**When** the drift check runs in its current aligned state.
**Then** the job passes and the step summary confirms alignment.
