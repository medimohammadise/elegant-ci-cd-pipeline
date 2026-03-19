# Data Model: Reusable Release Notes and Version Automation

## Pull Request Release Metadata

Purpose: Represents the classification data attached to a merged pull request that drives release-note grouping and version impact.

Fields:
- `pull_request_id`: Unique identifier for the merged pull request.
- `title`: Human-readable summary of the merged change.
- `merged_at`: Merge timestamp used for release boundary evaluation.
- `base_branch`: Primary branch into which the pull request was merged.
- `release_category`: Category used to group the change in release notes.
- `version_impact`: Declared semantic impact of the change: `major`, `minor`, `patch`, or `unspecified`.
- `author_display_name`: Optional author attribution for release notes.
- `pull_request_link`: Optional reference link for human-readable notes.
- `revert_reference`: Optional relationship to a pull request this change reverts or is reverted by.
- `eligibility_status`: Classification result such as `included`, `excluded_reverted`, `excluded_out_of_range`, or `excluded_invalid`.

Validation rules:
- Each merged pull request must map to exactly one eligibility status.
- `version_impact` must resolve to at most one semantic bump level.
- Missing category metadata must trigger the configured fallback path.
- Conflicting version metadata must produce an invalid state rather than silent coercion.

## Release Candidate Set

Purpose: Represents the collection of merged pull requests eligible for the next release.

Fields:
- `release_boundary_reference`: The prior release marker used as the lower bound for eligibility.
- `base_branch`: Branch against which release eligibility is evaluated.
- `candidate_pull_requests`: Ordered set of included pull request metadata records.
- `excluded_pull_requests`: Pull requests excluded from the release with explicit reasons.
- `evaluation_timestamp`: Time at which the release set was assembled.
- `release_required`: Boolean indicating whether any releasable changes remain after filtering.

Validation rules:
- Included pull requests must be merged after the selected release boundary.
- No pull request may appear more than once in the candidate set.
- Every excluded pull request must carry an explicit exclusion reason.

State transitions:
- `collecting` -> `classified` when all merged pull requests have category and version evaluation results.
- `classified` -> `ready_for_release` when at least one included pull request remains.
- `classified` -> `no_release_required` when no included pull requests remain.
- `classified` -> `invalid` when contradictory metadata prevents a deterministic outcome.

## Version Decision

Purpose: Represents the semantic version conclusion for the release candidate set.

Fields:
- `current_version`: Most recent released version, if available.
- `selected_bump`: Highest required bump among `major`, `minor`, `patch`, or `none`.
- `next_version`: Next version string derived from the selected bump and current version policy.
- `decision_reason`: Human-readable explanation of why the bump was selected.
- `contributing_pull_requests`: Included pull requests whose metadata justified the selected bump.

Validation rules:
- `selected_bump` must be the highest precedence bump present in the release candidate set.
- `selected_bump` is `none` only when `release_required` is false.
- `contributing_pull_requests` must reference included pull requests only.

## Release Notes Document

Purpose: Represents the generated release summary that downstream workflows can publish or review.

Fields:
- `release_title`: Human-readable title for the pending release.
- `notes_markdown`: Structured release notes in human-readable form.
- `notes_json`: Structured representation of release-note categories and entries.
- `sections`: Ordered list of release-note sections.
- `included_pull_request_count`: Number of included pull requests summarized in the notes.
- `excluded_summary`: List of excluded pull requests and reasons surfaced for transparency.
- `generated_from_boundary`: Boundary reference used to build the release notes.

Validation rules:
- Every included pull request must appear in exactly one release-note section.
- Section ordering must be deterministic for the same inputs.
- Excluded pull requests must not appear in release-note sections.

## Release Note Section

Purpose: Represents a category grouping inside the release notes document.

Fields:
- `section_name`: Display name for the category.
- `section_order`: Deterministic order value for rendering.
- `entries`: Pull request summaries belonging to the section.
- `is_fallback_section`: Boolean indicating whether the section is used for unlabeled or defaulted changes.

Validation rules:
- A fallback section may appear at most once.
- Entries inside a section must be uniquely identified by pull request.
