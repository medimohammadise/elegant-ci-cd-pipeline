# Contract Scenarios: ci-action-version-drift

## Purpose

Validate the external contract for the action version drift check — both the
shell script interface and the CI workflow that invokes it.

## Script Contract: check-action-versions.sh

1. Given `.github/actions-versions.yml` exists and all workflow `uses:` references
   match the manifest, the script exits `0` and prints a single success line.
2. Given one or more workflow files contain an action version that differs from the
   manifest, the script exits `1` and the output names the file path, line number,
   action identifier, found version, and expected version for each mismatch.
3. Given a workflow file contains a `uses:` line referencing an action not present
   in the manifest, the script exits `1` when invoked with `--strict` and reports
   the action as unregistered.
4. Given `.github/actions-versions.yml` does not exist, the script exits `2` and
   writes a descriptive error to stderr.
5. Local workflow references (`uses: ./.github/workflows/...`) are not reported as
   mismatches or unregistered actions regardless of manifest contents.

## CI Workflow Contract: ci-action-version-drift.yml

6. The workflow is triggered on `pull_request` events for paths matching `.github/**`.
7. The workflow can be triggered manually via `workflow_dispatch` with no required inputs.
8. The workflow declares `permissions: contents: read` and no additional permissions.
9. On a clean run (no drift), the job passes and the step summary confirms alignment.
10. On a drift detection run, the job fails and the step summary contains the full
    drift report produced by the script.
11. The workflow does not push, comment, or modify repository state — it only reads
    and reports.
