# Integration Scenarios: Issue Spec Artifacts

## Goal

Verify prompt preparation and downstream Codex dispatch for an eligible issue.

## Scenarios

1. Open an issue with a feature request body that includes clear scope and behavior.
2. Confirm the workflow derives a deterministic target branch and `specs/` directory from the issue metadata.
3. Confirm the workflow packages the issue metadata and planning instructions into the downstream dispatch payload.
4. Confirm the workflow sends one `repository_dispatch` request to the configured Codex pipeline repository.
5. Confirm the issue comment records `handoff_started` and includes the prompt reference and target artifact locations.
6. Simulate a dispatch failure and confirm the issue comment records `failed` with a dispatch-specific message.
