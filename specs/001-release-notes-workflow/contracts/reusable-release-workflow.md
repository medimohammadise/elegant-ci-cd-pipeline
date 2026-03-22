# Contract: Reusable Release Workflow

## Purpose

Define the callable interface for a shared release-decision and release-notes workflow that can be invoked by multiple repositories without embedding repository-local helper scripts.

## Responsibilities

The reusable workflow is responsible for:
- Identifying merged pull requests on the primary branch after the chosen release boundary
- Applying configured category and version-mapping rules
- Excluding ineligible or reverted changes according to policy
- Selecting the required semantic version bump
- Producing machine-consumable and human-readable release artifacts

The reusable workflow is not responsible for:
- Building or testing application code
- Creating tags or publishing releases
- Deploying artifacts
- Sending notifications outside the release-decision scope

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `base_branch` | Yes | Primary branch used to evaluate merged pull requests and release eligibility. |
| `release_boundary` | No | Explicit prior release marker. If omitted, the workflow resolves the latest reachable release marker automatically. |
| `category_rules` | Yes | Mapping that assigns pull request metadata values to release-note categories and their display order. |
| `version_rules` | Yes | Mapping that assigns pull request metadata values to semantic version impact levels. |
| `unlabeled_behavior` | No | Policy for pull requests with no recognized category or version metadata. |
| `revert_handling` | No | Policy describing whether reverted pull requests are excluded and how exclusions are reported. |
| `include_pr_links` | No | Whether pull request links should appear in human-readable notes. |
| `include_authors` | No | Whether author attribution should appear in human-readable notes. |

## Outputs

| Output | Description |
|--------|-------------|
| `release_required` | Indicates whether any releasable changes remain after filtering and validation. |
| `version_bump` | Selected semantic bump level: `major`, `minor`, `patch`, or `none`. |
| `next_version` | The next resolved version string when a release is required. |
| `release_notes_markdown` | Human-readable release notes body ready for downstream publishing steps. |
| `release_notes_json` | Structured release-note content for machine consumption. |
| `included_pr_count` | Number of merged pull requests included in the release notes. |
| `excluded_prs_with_reasons` | Structured list of excluded pull requests with explicit reasons. |
| `decision_reason` | Human-readable explanation of the selected release outcome. |

## Behavioral Rules

1. The workflow evaluates only merged pull requests after the release boundary on the configured base branch.
2. The workflow chooses the highest required version impact present across all included pull requests.
3. Unlabeled pull requests must not be omitted silently.
4. Conflicting version indicators must fail the workflow with an actionable explanation.
5. Reverted pull requests must be excluded when the configured revert policy and matching evidence allow deterministic exclusion.
6. If no releasable changes remain, the workflow returns `release_required = false` and `version_bump = none`.

## Consumer Expectations

Consuming repositories are expected to:
- Maintain a consistent pull request label or metadata taxonomy
- Define or accept the shared category and version mappings
- Invoke this workflow from broader release automation when they need release notes or version decisions
- Use the emitted outputs in later tagging, publishing, deployment, or notification steps

## Validation Scenarios

- Patch-only merged history produces a patch bump and grouped notes.
- Minor and patch changes together produce a minor bump.
- Any major-classified change produces a major bump.
- Unlabeled changes appear in the fallback section and are surfaced clearly.
- Conflicting metadata fails with the affected pull request identified.
- Reverted changes are excluded from both notes and version impact when matched before release generation.
- Empty histories produce a `no releasable changes` result.
