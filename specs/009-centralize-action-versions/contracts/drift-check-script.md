# Contract: check-action-versions.sh

**Type**: Shell script (CLI tool)
**Location**: `.specify/scripts/bash/check-action-versions.sh`
**Date**: 2026-03-29

---

## Interface

### Invocation

```bash
.specify/scripts/bash/check-action-versions.sh [OPTIONS]
```

### Options

| Flag | Description | Default |
| ---- | ----------- | ------- |
| `--manifest <path>` | Path to the version manifest YAML | `.github/actions-versions.yml` |
| `--workflows-dir <path>` | Directory containing workflow files to scan | `.github/workflows` |
| `--strict` | Treat unregistered actions as failures (in addition to version mismatches) | off |

### Exit Codes

| Code | Meaning |
| ---- | ------- |
| `0` | All checked action references match the manifest |
| `1` | One or more mismatches or unregistered actions detected |
| `2` | Manifest file not found or unreadable |

### stdout

- On success: single line `✓ All action versions aligned with manifest.`
- On failure: drift report (see data-model.md DriftReport format)

### stderr

- Error messages only (file not found, parse errors)

---

## Contract: ci-action-version-drift.yml

**Type**: GitHub Actions reusable workflow (also standalone `workflow_dispatch`)
**Location**: `.github/workflows/ci-action-version-drift.yml`

### Triggers

| Trigger | Paths / Conditions |
| ------- | ------------------ |
| `pull_request` | `.github/**` |
| `workflow_dispatch` | manual trigger, no inputs required |

### Inputs

None required. The workflow uses repository-default paths for manifest and workflows directory.

### Outputs

None declared.

### Permissions

```yaml
permissions:
  contents: read
```

### Behavior

1. Checks out the repository at the PR head commit
2. Runs `.specify/scripts/bash/check-action-versions.sh --strict`
3. Fails the job if the script exits non-zero
4. Annotates the PR with the drift report (via `$GITHUB_STEP_SUMMARY`)

### Failure Modes

| Scenario | Behavior |
| -------- | -------- |
| Manifest missing | Job fails with error: manifest file not found |
| Version mismatch found | Job fails; report printed to step summary |
| Unregistered action found | Job fails with `--strict` (default in CI) |
| No workflow files found | Job passes with warning to step summary |
