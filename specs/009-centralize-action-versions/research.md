# Research: Centralized GitHub Actions Version Management

**Feature**: 009-centralize-action-versions
**Date**: 2026-03-29

---

## Decision 1: Centralization Mechanism

**Decision**: Version manifest file (`.github/actions-versions.yml`) + drift-check shell script

**Rationale**: GitHub Actions has no native "version catalog" equivalent to Gradle's `libs.versions.toml`. The only practical approaches are:
1. A standalone manifest + validation script (chosen)
2. Composite wrapper actions that pin versions internally
3. Pure Dependabot reliance (no enforcement)

Option 1 matches this repo's existing patterns: all tooling is shell scripts, no framework dependencies, no new toolchain needed. Composite wrapper actions would require a separate repository or local action per dependency — high overhead for simple version pinning.

**Alternatives considered**:
- **Composite wrapper actions**: Each external action wrapped in a local composite action that hard-codes the version. Rejected — adds a maintenance layer for every action, breaks the familiar `uses: actions/checkout@vX` syntax, and increases surface area.
- **Strict Dependabot-only approach**: Rely on Dependabot's grouped PRs to keep all workflow files in sync. Rejected — does not prevent human contributors from hard-coding arbitrary versions in new workflows; no enforcement gate.

---

## Decision 2: Manifest Format

**Decision**: YAML file at `.github/actions-versions.yml` with a flat `actions:` map

```yaml
# .github/actions-versions.yml
# Single source of truth for approved GitHub Actions versions.
# Update this file when bumping a version; the CI drift check enforces alignment.

actions:
  actions/checkout: v6
  actions/setup-java: v5
  actions/github-script: v8
  actions/upload-artifact: v7
  actions/attest-build-provenance: v4
  docker/setup-buildx-action: v4
  docker/login-action: v4
  docker/metadata-action: v6
  docker/build-push-action: v7
  gradle/actions/setup-gradle: v6
  peter-evans/create-pull-request: v8
  JetBrains/qodana-action: v2025.3.2
```

**Rationale**: Flat map is the simplest structure a shell script can parse with `yq` or `grep`/`awk`. No nesting, no per-workflow overrides needed for the current action inventory. Adding a `description:` sub-key per action is supported later without breaking the parser.

**Alternatives considered**:
- **Per-workflow manifest sections**: Allows intentional version divergence per workflow. Rejected for now — current inventory has no divergence cases; adds complexity without benefit. Can be added as an exceptions list later.
- **JSON format**: Equally parseable but less readable than YAML for hand-editing. Rejected.

---

## Decision 3: Drift Check Implementation

**Decision**: Bash script at `.specify/scripts/bash/check-action-versions.sh` invoked by a CI workflow

**Rationale**: Consistent with existing tooling (all repo scripts are bash). The script:
1. Reads the manifest using `grep`/`awk` (avoids `yq` dependency — not guaranteed on GitHub-hosted runners)
2. Scans all `.github/workflows/*.yml` files for `uses:` lines
3. Skips local workflow refs (`uses: ./.github/workflows/...`)
4. Skips `workflow_call` / internal references
5. For each external action reference, extracts `<owner>/<action>@<version>` and compares against the manifest
6. Exits non-zero and prints a formatted report if any mismatch is found

**Alternatives considered**:
- **Python script**: More robust YAML parsing. Rejected — introduces a Python dependency with no other Python tooling in the repo.
- **GitHub Action (third-party)**: e.g., a marketplace action that checks version pinning. Rejected — adds an external dependency that itself needs version management (circular).
- **yq-based parsing**: Cleaner YAML parsing but `yq` is not pre-installed on all runners. Rejected in favor of portable bash.

---

## Decision 4: CI Trigger Strategy

**Decision**: New workflow `ci-action-version-drift.yml` triggered on `pull_request` paths: `.github/**` and `.github/actions-versions.yml`

**Rationale**: The check only needs to run when workflow files or the manifest change. Running on every push to main is also added as a safety net. This follows the repo convention of small, purpose-specific CI workflows.

**Dependabot integration**: When Dependabot opens a grouped PR bumping action versions, the PR will fail the drift check until the manifest is also updated. Two options:
- **Option A (manual)**: Maintainer updates manifest in the Dependabot PR before merging (simple, no automation)
- **Option B (automated)**: A post-Dependabot workflow reads updated versions from workflow files and auto-commits manifest updates

Option A is chosen for v1. Option B can be a follow-on feature.

---

## Decision 5: Scope Exclusions

The following `uses:` patterns are excluded from drift checking:
- Local references: `uses: ./.github/workflows/...`
- Actions pinned to full commit SHAs (treated as a manifest entry with the SHA as the version value)

**Rationale**: Local refs are internal workflow calls with no version to track. SHA-pinned actions are a security hardening choice; they should still be recorded in the manifest but comparison logic treats the SHA string as an opaque version.
