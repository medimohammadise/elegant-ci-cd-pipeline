# Feature Specification: Centralized GitHub Actions Version Management

**Feature Branch**: `009-centralize-action-versions`
**Created**: 2026-03-29
**Status**: Draft
**Input**: User description: "I would like to check what is the best practice for keeping used versions in this project for example we have actions/checkout in so many places as version 4 now new version according to dependency bump is 6 I want to have a centralized approach to keep them in sync"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update a Shared Action Version in One Place (Priority: P1)

A maintainer discovers (via a Dependabot PR or manual review) that `actions/checkout` should be bumped from v4 to v6. Today they must hunt through every workflow file and change each occurrence individually. With this feature, they update the version in a single manifest file, and all workflows reference that manifest — one edit propagates everywhere.

**Why this priority**: This is the core pain point. Inconsistent versions across workflows are the most likely source of broken builds after an upgrade, and the single-place-to-edit workflow eliminates the risk of partial updates.

**Independent Test**: Can be fully tested by editing the version for one action in the manifest and verifying that every workflow that uses that action reflects the updated version — delivering a verified "change once, apply everywhere" outcome.

**Acceptance Scenarios**:

1. **Given** `actions/checkout` is pinned to `v4` in the version manifest, **When** a maintainer changes it to `v6` in the manifest, **Then** all workflow files that reference `actions/checkout` use `v6` without any additional edits.
2. **Given** a workflow file references an action whose version is defined in the manifest, **When** the manifest is read, **Then** the resolved version matches the manifest entry exactly.
3. **Given** the manifest contains a version for an action, **When** a CI validation check runs, **Then** it passes with no drift warnings.

---

### User Story 2 - Detect Version Drift Before It Reaches Main (Priority: P2)

A contributor adds a new workflow and hard-codes `actions/checkout@v4` directly rather than referencing the manifest. Before merging, a CI check catches this drift and fails the pull request, prompting the contributor to align with the manifest.

**Why this priority**: Centralization is only effective if it is enforced. Without automated drift detection, new workflows will bypass the manifest, negating the investment.

**Independent Test**: Can be fully tested by introducing a deliberate version mismatch in a workflow file and running the validation check — it should report a failure identifying the offending file and line.

**Acceptance Scenarios**:

1. **Given** a workflow file contains an action version that differs from the manifest, **When** the CI version-drift check runs on a pull request, **Then** the check fails and reports the specific file, action, and conflicting versions.
2. **Given** all workflow files align with the manifest, **When** the CI version-drift check runs, **Then** the check passes with a clear success message.
3. **Given** a new workflow file is added without registering its actions in the manifest, **When** the drift check runs, **Then** it flags the unregistered actions as requiring manifest entries.

---

### User Story 3 - Onboard a New Workflow Without Guessing Approved Versions (Priority: P3)

A contributor writing a new workflow consults the manifest to find the project-approved version for any action they need. They do not have to search git history or grep existing files to discover which version is current.

**Why this priority**: Discoverability lowers the chance of contributors introducing stale or inconsistent versions. Lower priority because it is a developer-experience improvement rather than a correctness safeguard.

**Independent Test**: Can be fully tested by reading the manifest file alone and confirming it lists every action used across the project at its current approved version — delivering a self-contained reference document.

**Acceptance Scenarios**:

1. **Given** the manifest exists, **When** a contributor opens it, **Then** it lists every third-party action used in the project with its approved version and a brief purpose note.
2. **Given** a new action needs to be introduced, **When** the contributor adds it to the manifest first, **Then** the drift check accepts workflow files that reference that action at the registered version.

---

### Edge Cases

- What happens when Dependabot updates a version in a workflow file but the manifest is not updated? The drift check should fail until the manifest is also updated.
- What happens when the same action is intentionally pinned to different versions across workflows (e.g., a legacy workflow)? The manifest must support per-workflow overrides or explicit exceptions to avoid false-positive failures.
- How does the system handle actions pinned to a full commit SHA instead of a semver tag?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST have a single manifest file that records the approved version for every GitHub Actions action used across all workflow files.
- **FR-002**: The manifest MUST be the authoritative source of truth; workflow files MUST NOT hard-code action versions independently of the manifest.
- **FR-003**: A CI check MUST run on every pull request that modifies `.github/workflows/` or the manifest, comparing declared versions in workflow files against the manifest.
- **FR-004**: The CI drift check MUST report, for each mismatch, the workflow file path, the action name, the version found in the workflow, and the version expected from the manifest.
- **FR-005**: The CI drift check MUST exit with a non-zero status when any drift is detected, causing the pull request check to fail.
- **FR-006**: The manifest MUST list all actions currently in use at their latest project-approved versions as a baseline when first introduced.
- **FR-007**: The manifest MUST support listing a brief description or purpose for each action entry to serve as onboarding reference.
- **FR-008**: Dependabot MUST remain the mechanism for proposing version bumps; when Dependabot opens a PR, the manifest MUST also be updated in the same PR (or the drift check must enforce this).

### Key Entities

- **Version Manifest**: A single file (e.g., `.github/actions-versions.yml`) that maps each action identifier to its approved version and an optional description. Acts as the single source of truth.
- **Drift Check**: A CI job or script that reads the manifest and all workflow files, compares versions, and reports mismatches. Runs on pull requests.
- **Action Reference**: Each `uses: <action>@<version>` entry in a workflow file. Must match the manifest.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A maintainer can update any action version across the entire project by editing exactly one file (the manifest) — verified by confirming no other files require edits for the version change to take effect.
- **SC-002**: The CI drift check catches 100% of version mismatches between workflow files and the manifest within a single pull request validation run.
- **SC-003**: A contributor can identify the project-approved version for any in-use action in under 30 seconds by consulting the manifest alone.
- **SC-004**: After the feature is implemented, zero pull requests are merged to `main` that introduce an action version not recorded in the manifest, as enforced by the drift check gate.

## Assumptions

- Dependabot is already configured and will continue to be the mechanism for discovering and proposing new action versions; this feature does not replace Dependabot.
- The version manifest will be a hand-maintained or script-assisted file — full automatic injection of manifest values into workflow YAML at CI time is out of scope for this feature (workflows retain their `uses:` lines; the drift check validates them).
- Actions pinned to full commit SHAs (for security hardening) are treated as equivalent to semver tags in the manifest; the manifest records whichever pin form the project uses.
- All workflow files reside under `.github/workflows/` in this repository.
- Intentional per-workflow version exceptions (e.g., a legacy workflow on an older action version) are rare; if needed, the manifest can support an explicit override or allowlist entry.
