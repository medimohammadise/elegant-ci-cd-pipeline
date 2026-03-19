# Quickstart: Reusable Release Notes and Version Automation

## What This Feature Provides

This feature adds a shared release-decision workflow that repositories can call to:
- identify merged pull requests since the last release
- group changes into release-note sections from pull request metadata
- select the correct semantic version bump
- return structured outputs for downstream release steps

## Preconditions

Before adopting the shared workflow, a consuming repository should have:
- a primary branch used as the release source of truth
- pull request labels or equivalent metadata that distinguish patch, minor, and major changes
- a release boundary strategy based on tags or another explicit release marker
- downstream workflow steps that consume a release decision, release notes, or both

## Required Policy Inputs

Each consuming repository must define or accept:
- the base branch to inspect
- the metadata-to-category mapping used for release-note sections
- the metadata-to-version mapping used for semantic bump decisions

Optional policy inputs:
- how unlabeled pull requests are handled
- whether reverted pull requests are excluded automatically
- whether release notes include pull request links
- whether release notes include author attribution

## Expected Outputs

The shared workflow returns:
- whether a release is required
- the selected bump level
- the next version string
- release notes in markdown
- a structured release summary for downstream automation
- excluded pull requests with reasons

## Example Consumer Flow

1. A repository merges pull requests into its primary branch.
2. A release workflow calls the shared release-decision workflow.
3. The shared workflow identifies eligible pull requests since the last release boundary.
4. It applies category and version rules, excludes invalid or reverted changes, and selects the highest bump.
5. The calling workflow uses the returned version and release notes for tagging, publishing, approvals, or notifications.

## Example Label Taxonomy

Suggested version-impact labels:
- `release:major`
- `release:minor`
- `release:patch`

Suggested release-note categories:
- `type:feature`
- `type:fix`
- `type:docs`
- `type:maintenance`

Suggested fallback behavior:
- unlabeled changes go to `Other Changes`
- unlabeled changes are treated conservatively unless strict validation is enabled

## Failure Cases

Expect the workflow to stop clearly when:
- a pull request carries conflicting version indicators
- required release metadata cannot be interpreted
- the release boundary cannot be resolved deterministically

Expect a non-release outcome, not a failure, when:
- no eligible merged pull requests exist after the release boundary

## Verification Steps

Validate adoption with sample histories covering:
- only patch-level changes
- a mix of minor and patch changes
- at least one major change
- unlabeled pull requests
- reverted pull requests
- no releasable changes after the current release boundary

Verification note:
- Prefer scenario-based workflow validation, fixture histories, static checks, and controlled dry runs over conventional application-style unit tests, since this feature is primarily GitHub Actions source code.
