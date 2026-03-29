# Contract Scenarios: Issue Spec Artifacts

## Purpose

Validate the prompt-package and handoff contract for the standalone Codex pipeline.

## Scenarios

1. The prompt package includes `prompt_id`, issue number, issue title, issue body, issue URL, and planning instructions.
2. The prompt package includes derived `target_branch_name` and `target_specs_dir` values for the downstream pipeline.
3. The workflow dispatches the prompt package through `repository_dispatch` using the configured pipeline repository and event type.
4. The workflow records `handoff_started` only when prompt preparation succeeded and dispatch did not fail.
5. The workflow reports `failed` when dispatch to the Codex pipeline fails after prompt preparation.
