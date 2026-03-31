# Quickstart: Centralized GitHub Actions Version Management

**Feature**: 009-centralize-action-versions

---

## Day-to-Day Workflows

### Updating an Action Version

1. Open `.github/actions-versions.yml`
2. Change the nested `version:` value for the action entry (for example, `actions/checkout` from `version: v6` to `version: v7`)
3. Run the drift check locally to confirm the manifest and all workflow files are aligned:
   ```bash
   bash .specify/scripts/bash/check-action-versions.sh --strict
   ```
4. Update any workflow files that still reference the old version
5. Open a PR — the `ci-action-version-drift` check validates alignment before merge

### Handling a Dependabot Version Bump PR

Dependabot updates versions directly in workflow files. The manifest must also be updated in the same PR:

1. In the Dependabot PR, edit `.github/actions-versions.yml` to match the new versions
2. Run the drift check locally:
   ```bash
   bash .specify/scripts/bash/check-action-versions.sh --strict
   ```
3. Push the manifest update — the CI drift check will now pass

### Adding a New Workflow with a New Action

1. Add the new action to `.github/actions-versions.yml` first:
   ```yaml
   actions:
     owner/new-action:
       version: v3
       description: Brief purpose note for contributors
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
  # Format: <owner>/<repo>[/<subpath>]:
  #   version: <exact tag or full SHA>
  #   description: <brief purpose note>
  actions/checkout:
    version: v6
    description: Check out repository source code
  gradle/actions/setup-gradle:
    version: v6
    description: Set up Gradle with caching for faster CI builds
  JetBrains/qodana-action:
    version: v2025.3.2
    description: Run JetBrains Qodana static code analysis
```

---

## Running the Drift Check Locally

```bash
# Default (uses .github/actions-versions.yml and .github/workflows/)
bash .specify/scripts/bash/check-action-versions.sh

# Custom paths
bash .specify/scripts/bash/check-action-versions.sh \
  --manifest .github/actions-versions.yml \
  --workflows-dir .github/workflows

# Strict mode: also fail on unregistered actions
bash .specify/scripts/bash/check-action-versions.sh --strict
```
