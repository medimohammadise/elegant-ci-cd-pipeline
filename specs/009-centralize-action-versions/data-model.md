# Data Model: Centralized GitHub Actions Version Management

**Feature**: 009-centralize-action-versions
**Date**: 2026-03-29

---

## Entities

### Version Manifest (`.github/actions-versions.yml`)

The authoritative file. One entry per external action used anywhere in `.github/workflows/`.

```
ManifestEntry:
  key:         <owner>/<repo>[/<subpath>]   # e.g., "actions/checkout", "gradle/actions/setup-gradle"
  version:     <semver-tag | commit-sha>    # e.g., "v6", "v2025.3.2", "abc1234..."
  description: <string> (optional)          # human-readable purpose note
```

**Constraints**:
- Keys are unique within the manifest
- Version string must not be empty
- Version string may be a semver tag (`vN`, `vN.N`, `vN.N.N`) or a full 40-char commit SHA
- No wildcards or ranges (exact version only)

---

### Action Reference (workflow `uses:` line)

Each occurrence of an external action in a workflow file.

```
ActionReference:
  file:    <relative-path>     # e.g., ".github/workflows/backend-docker-build.yml"
  line:    <integer>           # line number in file
  action:  <owner>/<repo>[/…]  # extracted from "uses: <action>@<version>"
  version: <string>            # extracted version tag or SHA
```

**Exclusion rules** (not validated):
- `uses:` values starting with `./.github/` → local workflow ref, skip
- `uses:` values with no `@` → reusable local call, skip

---

### Drift Report (script stdout)

The output produced when the drift check detects mismatches.

```
DriftReport:
  mismatches: []DriftEntry
  unregistered: []ActionReference   # action found in workflow but not in manifest

DriftEntry:
  file:             <path>
  line:             <integer>
  action:           <string>
  found_version:    <string>
  expected_version: <string>
```

**Example output**:

```
DRIFT DETECTED: 2 mismatch(es) found

  [MISMATCH] .github/workflows/backend-docker-build.yml:53
             actions/checkout — found: v4, expected: v6

  [UNREGISTERED] .github/workflows/new-workflow.yml:12
             some/new-action@v2 — not in .github/actions-versions.yml

ACTION REQUIRED: Update workflow files or register actions in the manifest.
Exit code: 1
```

---

## State Transitions

The manifest and workflow files move through these states across a typical Dependabot upgrade cycle:

```
1. ALIGNED
   manifest version == all workflow file versions  →  drift check: PASS

2. DRIFTED (Dependabot PR opened)
   Dependabot bumps versions in workflow files
   manifest still has old versions              →  drift check: FAIL

3. RESOLVED (maintainer updates manifest in same PR)
   manifest updated to match new versions       →  drift check: PASS → merge
```
