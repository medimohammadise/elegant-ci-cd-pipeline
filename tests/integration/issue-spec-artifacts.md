# Integration Scenarios: Issue Spec Artifacts

## Goal

Verify prompt preparation and downstream reusable workflow execution for an eligible issue.

## Scenarios

1. Open an issue with a feature request body that includes clear scope and behavior.
2. Confirm the workflow prepares `$speckit.specify <issue body>` as the downstream command input.
3. Confirm the workflow calls `.github/workflows/codex-spec-kit-agent.yml` exactly once.
4. Confirm the issue comment records `handoff_started` and includes the prompt reference and downstream workflow path.
5. Confirm the downstream workflow creates or updates the planning artifacts.
6. Simulate a reusable-workflow failure and confirm the issue comment records `failed` with a downstream-call-specific message.
