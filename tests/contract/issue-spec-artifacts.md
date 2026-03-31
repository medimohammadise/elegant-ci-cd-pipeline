# Contract Scenarios: Issue Spec Artifacts

## Purpose

Validate the prompt and reusable-workflow handoff contract for the downstream Codex Spec Kit workflow.

## Scenarios

1. The downstream command input is built as `$speckit.specify <normalized issue body>`.
2. The issue-opened workflow calls `.github/workflows/codex-spec-kit-agent.yml` through `workflow_call`.
3. The issue-opened workflow records `handoff_started` only when the reusable workflow call succeeds.
4. The workflow reports `failed` when the reusable workflow call fails after prompt preparation.
5. The downstream workflow can use the supplied prompt to generate `spec.md`, `plan.md`, `tasks.md`, and `checklists/requirements.md`.
