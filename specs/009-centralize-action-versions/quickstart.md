# Quickstart: Centralized GitHub Actions Version Management

**Feature**: 009-centralize-action-versions

---

## Day-to-Day Workflows

### Updating an Action Version

1. Open `.github/actions-versions.yml`
2. Change the version value for the action (e.g., `actions/checkout: v6` → `actions/checkout: v7`)
3. Run the drift check locally to confirm the manifest and all workflow files are aligned:
   ```bash
   .specify/scripts/bash/check-action-versions.sh
   ```
4. Update any workflow files that still reference the old version
5. Open a PR — the `ci-action-version-drift` check validates alignment before merge

### Handling a Dependabot Version Bump PR

Dependabot updates versions directly in workflow files. The manifest must also be updated in the same PR:

1. In the Dependabot PR, edit `.github/actions-versions.yml` to match the new versions
2. Run the drift check locally:
   ```bash
   .specify/scripts/bash/check-action-versions.sh
   ```
3. Push the manifest update — the CI drift check will now pass

### Adding a New Workflow with a New Action

1. Add the new action to `.github/actions-versions.yml` first:
   ```yaml
   actions:
     owner/new-action: v3
   ```
2. Reference it in your workflow file:
   ```yaml
   - uses: owner/new-action@v3
   ```
3. The drift check will pass because the manifest entry exists

### Adding a New Workflow Using an Existing Action

Just reference the version already in the manifest. No manifest update needed.

---

## Manifest Format Reference

```yaml
# .github/actions-versions.yml
actions:
  # Format: <owner>/<repo>[/<subpath>]: <version>
  actions/checkout: v6
  actions/setup-java: v5
  gradle/actions/setup-gradle: v6
  JetBrains/qodana-action: v2025.3.2   # non-semver tags are supported
```

---

## Running the Drift Check Locally

```bash
# Default (uses .github/actions-versions.yml and .github/workflows/)
.specify/scripts/bash/check-action-versions.sh

# Custom paths
.specify/scripts/bash/check-action-versions.sh \
  --manifest .github/actions-versions.yml \
  --workflows-dir .github/workflows

# Strict mode: also fail on unregistered actions
.specify/scripts/bash/check-action-versions.sh --strict
```
