# Feature Specification: Reusable Release Notes and Version Automation

**Feature Branch**: `[001-release-notes-workflow]`  
**Created**: 2026-03-19  
**Status**: Draft  
**Input**: User description: "Reusable GitHub Actions workflow for generating release notes based on PR labels, automatically determining semantic version (major/minor/patch) from PR metadata upon merge to main. Designed as a callable workflow (workflow_call) so it can be reused across repositories, with release-note logic isolated from other CI/CD steps and without relying on non-reusable local scripts."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Publish consistent release summaries (Priority: P1)

As a release maintainer, I want merged pull requests to produce release notes automatically so every release has a complete, label-driven summary without requiring manual compilation.

**Why this priority**: This is the primary user value. Without reliable release-note generation, the feature does not reduce release effort or improve consistency.

**Independent Test**: Can be fully tested by merging labeled pull requests into the primary branch and confirming that the generated release notes group and describe included changes correctly.

**Acceptance Scenarios**:

1. **Given** one or more pull requests with recognized release labels have been merged into the primary branch, **When** a release is prepared, **Then** the system generates release notes that include those pull requests under the correct categories.
2. **Given** a merged pull request has no recognized release label, **When** release notes are generated, **Then** the system applies the default handling rule defined for unlabeled changes and does not omit the change silently.
3. **Given** multiple merged pull requests belong to different release-note categories, **When** release notes are generated, **Then** the output separates entries by category in a predictable order.

---

### User Story 2 - Determine the correct semantic version bump (Priority: P1)

As a release maintainer, I want the next version number to be selected automatically from pull request metadata so versioning stays aligned with the significance of merged changes.

**Why this priority**: Automatic version selection is core to the release decision. If it is wrong or inconsistent, downstream release automation becomes unreliable.

**Independent Test**: Can be fully tested by merging pull requests representing patch, minor, and major changes and verifying that the highest required version increment is selected for the next release.

**Acceptance Scenarios**:

1. **Given** only pull requests marked as patch-level changes have been merged since the last release, **When** the next release is prepared, **Then** the version increases by one patch increment.
2. **Given** at least one pull request marked as a minor change and no pull requests marked as a major change have been merged since the last release, **When** the next release is prepared, **Then** the version increases by one minor increment.
3. **Given** at least one pull request marked as a major change has been merged since the last release, **When** the next release is prepared, **Then** the version increases by one major increment regardless of lower-severity changes also included.

---

### User Story 3 - Reuse the automation across repositories (Priority: P2)

As a platform or repository maintainer, I want the release-note and versioning process to be callable from multiple repositories so the organization can standardize release behavior without duplicating custom logic.

**Why this priority**: Reuse reduces maintenance cost and drift, but the feature still provides value in a single repository before broader adoption.

**Independent Test**: Can be fully tested by invoking the same release automation from two repositories with different pull request histories and confirming both receive the same behavior and output structure.

**Acceptance Scenarios**:

1. **Given** two repositories invoke the shared release automation, **When** each prepares a release, **Then** both use the same version-selection rules and release-note structure without repository-specific scripts.
2. **Given** a consuming repository integrates the shared release automation into a broader delivery pipeline, **When** the release-note step runs, **Then** it can operate independently of unrelated build, test, or deployment steps.

### Edge Cases

- What happens when no pull requests have been merged since the most recent release marker?
- How does the system handle a pull request that carries conflicting version indicators?
- How does the system handle pull requests that are reverted before the next release is prepared?
- What happens when release-note categories are missing, duplicated, or use unrecognized labels?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST generate release notes automatically for changes merged into the primary branch after the most recent release boundary.
- **FR-002**: The system MUST derive release-note sections from pull request labels or equivalent pull request metadata that classify the type of change.
- **FR-003**: The system MUST include each eligible merged pull request at most once in the generated release notes.
- **FR-004**: The system MUST define and apply a deterministic fallback rule for merged pull requests that lack a recognized release-note label.
- **FR-005**: The system MUST determine the next semantic version by evaluating merged pull request metadata and selecting the highest required increment among major, minor, and patch.
- **FR-006**: The system MUST treat major changes as higher priority than minor changes, and minor changes as higher priority than patch changes, when multiple change levels are present in the same release.
- **FR-007**: The system MUST generate the same version result and release-note structure when invoked from different repositories using the same inputs and rules.
- **FR-008**: The system MUST be callable as a standalone release automation unit so repositories can use it without embedding repository-local helper scripts.
- **FR-009**: The system MUST expose the generated version and release-note output in a form that downstream release steps can consume.
- **FR-010**: The system MUST fail with a clear, actionable message when required pull request metadata is missing, contradictory, or cannot be interpreted.
- **FR-011**: The system MUST support execution when merged pull requests include a mix of categorized, uncategorized, and reverted changes, following documented precedence rules.
- **FR-012**: Repository maintainers MUST be able to understand which labels or metadata values map to each release-note category and version increment.

### Key Entities *(include if feature involves data)*

- **Pull Request Release Metadata**: The labels or metadata attached to a merged pull request that determine release-note category and semantic version impact.
- **Release Candidate Set**: The collection of merged pull requests eligible to appear in the next release because they occurred after the last release boundary and were not already included.
- **Release Notes Document**: The structured summary of categorized changes prepared for a release and intended for downstream publication or approval.
- **Version Decision**: The selected major, minor, or patch increment for the next release, including the rationale derived from merged pull request metadata.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Release maintainers can prepare release notes for a standard release in under 5 minutes without manually reviewing individual pull requests for categorization.
- **SC-002**: In validation runs covering patch-only, minor-inclusive, and major-inclusive release histories, the selected version increment matches the expected outcome in 100% of cases.
- **SC-003**: At least 95% of merged pull requests intended for a release appear in the generated release notes under the correct category on the first run, with any exceptions explained explicitly.
- **SC-004**: A consuming repository can adopt the shared release automation without adding repository-specific helper scripts for release-note generation or version selection.
- **SC-005**: When required metadata is missing or conflicting, maintainers receive a clear failure reason within one execution attempt and can identify the affected pull request without additional investigation tools.

## Assumptions

- The organization already uses a consistent pull request labeling or metadata practice that can distinguish major, minor, and patch changes.
- The primary branch is the source of truth for released changes.
- A prior release boundary exists or can be inferred so the next release includes only newly merged pull requests.
- Reverted pull requests remain visible in merge history and can be identified for exclusion or special handling by documented rules.
