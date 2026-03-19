# Workflow Call Contract

## Inputs

Required or supported inputs:

- `base_branch`
- `release_boundary`
- `category_rules`
- `version_rules`
- `unlabeled_behavior`
- `revert_handling`
- `include_pr_links`
- `include_authors`

## Outputs

The workflow must set:

- `release_required`
- `version_bump`
- `next_version`
- `release_notes_markdown`
- `release_notes_json`
- `included_pr_count`
- `excluded_prs_with_reasons`
- `decision_reason`

## Consumer Expectations

- The workflow is reusable through `workflow_call`.
- Consumers do not need repository-local helper scripts to invoke it.
- Outputs remain stable across repositories using the same metadata policy.
- Empty release sets return `release_required = false` and `version_bump = none`.
