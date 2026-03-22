# Release Notes Output Expectations

## Markdown Output

Expected characteristics:

- Sections are grouped by category.
- `Other Changes` appears when a pull request has no recognized category label.
- Entries remain deterministic for the same merged pull request set.
- Pull request links and authors appear only when the related inputs are enabled.

## JSON Output

Expected characteristics:

- Includes `base_branch`, `release_boundary`, `release_required`, `version_bump`, `next_version`, and `sections`.
- Each section contains pull request number, title, URL, author, and version impact.
- Excluded pull requests are reported separately through `excluded_prs_with_reasons`.
