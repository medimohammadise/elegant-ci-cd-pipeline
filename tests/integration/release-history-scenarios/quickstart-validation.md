# Quickstart Validation

## Validation Approach

Use scenario-based review and controlled dry runs to validate the reusable workflow:

- review workflow inputs and outputs against `docs/reusable-release-notes.md`
- confirm release policy alignment against `docs/release-policy.md`
- validate that the workflow exposes all documented outputs
- validate that empty-release and failure messages are documented and surfaced consistently

## Dry Run Checklist

- Confirm `workflow_call` inputs match the published contract
- Confirm category rules and version rules can be overridden by callers
- Confirm `release_notes_markdown` and `release_notes_json` are both emitted
- Confirm `release_required = false` is returned for empty release sets
- Confirm conflicting labels lead to an actionable failure
