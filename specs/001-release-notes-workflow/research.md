# Research: Reusable Release Notes and Version Automation

## Semantic Version Selection

Decision: Select a single version bump for each release by evaluating all eligible merged pull requests since the release boundary and taking the highest impact present.

Rationale: This is deterministic and matches semantic version expectations: any breaking change dominates, otherwise any feature dominates, otherwise fixes or default changes result in a patch release.

Alternatives considered:
- Applying bumps sequentially in merge order was rejected because the result depends on pull request order.
- Using only the latest merged pull request was rejected because it can miss higher-impact changes already included in the same release.

## Version Precedence Rules

Decision: Use strict precedence `major > minor > patch`, where one major-classified pull request forces a major bump, otherwise any minor-classified pull request forces a minor bump, otherwise patch.

Rationale: A single breaking change must control release versioning, and the rule is simple to audit and explain across repositories.

Alternatives considered:
- Majority vote across labels was rejected because one breaking change can be outvoted incorrectly.
- Weighted scoring was rejected because it is harder to explain and verify.

## Release Boundary

Decision: Define the release boundary as the latest published release tag or other explicit release marker reachable from the primary branch.

Rationale: This gives a stable cutoff for “changes since last release” and survives reruns or failed workflow attempts.

Alternatives considered:
- A time-window cutoff was rejected because it is ambiguous.
- Using the previous workflow run as the boundary was rejected because retries and failures make it unreliable.

## Unlabeled Pull Requests

Decision: Include unlabeled pull requests in release notes under a fallback section such as `Other Changes`, and treat them conservatively as patch-level unless strict policy is configured.

Rationale: This prevents silent omission while keeping default versioning behavior safe.

Alternatives considered:
- Failing every unlabeled pull request was rejected as too disruptive for adoption.
- Excluding unlabeled pull requests from release notes was rejected because it produces incomplete release summaries.

## Conflicting Metadata

Decision: Fail the release decision when a pull request carries conflicting version indicators and no documented tie-break rule exists.

Rationale: Conflicting metadata is a source-data error and should be corrected explicitly rather than hidden by automation.

Alternatives considered:
- Automatically choosing the highest label was rejected because it masks process issues.
- Automatically choosing the lowest label was rejected because it risks under-versioning breaking changes.

## Reverted Pull Requests

Decision: Exclude reverted pull requests from both version calculation and release notes when the revert is merged before release generation and can be linked unambiguously to the original pull request.

Rationale: Release outputs should reflect net shipped behavior rather than transient merge history.

Alternatives considered:
- Keeping reverted pull requests with annotations was rejected because it adds noise.
- Ignoring revert relationships was rejected because it misrepresents what actually shipped.

## Empty Release Behavior

Decision: If no eligible merged pull requests exist after the release boundary, return `no releasable changes` and do not create a new version.

Rationale: Empty releases create noise and reduce trust in automation.

Alternatives considered:
- Always incrementing patch was rejected because it manufactures versions without user-visible change.
- Treating an empty release as a failure was rejected because it is a valid no-op outcome.

## Initial Release Behavior

Decision: If no prior release boundary exists, treat all qualifying merged pull requests on the primary branch as the initial release set.

Rationale: This gives a deterministic bootstrap path without requiring special manual seeding.

Alternatives considered:
- Requiring a manual initial version first was rejected because it adds setup friction.

## Reusable Workflow Contract Scope

Decision: Define a narrow callable contract centered on release intent rather than full release orchestration.

Rationale: The reusable workflow should only do what all consumers need: collect eligible merged pull requests, classify them, choose the semantic version bump, and emit release-note outputs. This keeps it reusable and composable with repository-specific tagging, publishing, and deployment steps.

Alternatives considered:
- A minimal contract with only a branch input and markdown output was rejected because consumers would still need custom rule logic.
- A broad workflow that also tags, publishes, or deploys was rejected because it couples unrelated delivery concerns and reduces reuse.

## Stable Inputs and Outputs

Decision: Treat inputs as policy controls and outputs as stable handoff artifacts.

Rationale: Stable inputs should cover only what varies by repository, while outputs should cover only what downstream steps need to continue safely.

Alternatives considered:
- A free-form configuration blob was rejected because it weakens validation and contract clarity.
- Only markdown output was rejected because downstream automation benefits from structured data too.

Selected contract direction:
- Inputs: `base_branch`, `release_boundary`, `category_rules`, `version_rules`, `unlabeled_behavior`, `revert_handling`, `include_pr_links`, `include_authors`
- Outputs: `release_required`, `version_bump`, `next_version`, `release_notes_markdown`, `release_notes_json`, `included_pr_count`, `excluded_prs_with_reasons`, `decision_reason`

## Isolation from Other CI/CD Steps

Decision: Keep release-note generation isolated from unrelated CI/CD steps.

Rationale: The shared workflow should stop at release intelligence: identifying candidate pull requests, classifying them, selecting the highest bump, and building outputs. Build, test, packaging, publishing, deployment, approvals, and notifications remain in the calling workflow.

Alternatives considered:
- Embedding release-note logic inside each repository pipeline was rejected because it creates duplication and drift.
- A monolithic release pipeline was rejected because unrelated failures would block reuse and make ownership unclear.

## Repository Structure

Decision: Structure the repository as a workflow distribution repository.

Rationale: For this feature, the clearest layout is a reusable workflow under `.github/workflows/`, policy guidance under `docs/`, and validation assets split between `tests/contract/` and `tests/integration/`.

Alternatives considered:
- A generic `src/` or `lib/` layout was rejected because this repo centers on reusable automation, not an application runtime.
- Putting all guidance inside workflow files was rejected because consumer-facing policy becomes harder to maintain.

## Workflow Validation Strategy

Decision: Validate the feature primarily through workflow-focused checks such as contract scenarios, release-history fixtures, static validation, and controlled dry-run review rather than assuming conventional application test cases.

Rationale: GitHub Actions workflow source code is automation configuration, not a typical application module with straightforward unit-test boundaries. Confidence should come from deterministic scenario coverage and contract validation aligned to real workflow behavior.

Alternatives considered:
- Requiring a conventional unit-test suite as the primary validation method was rejected because it does not match the main risk surface of workflow YAML and orchestration logic.
- Treating the workflow as effectively untestable was rejected because scenario-based and contract-based verification still provide meaningful coverage.
