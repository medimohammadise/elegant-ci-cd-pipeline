# Integration Scenarios: Issue Spec Automation Trigger

## Goal

Verify the highest-priority intake flow from issue creation through the reusable Codex Spec Kit handoff.

## Happy Path

1. Open a repository issue with a descriptive feature request body.
2. Confirm `.github/workflows/issue-spec-automation.yml` starts automatically from the `issues` `opened` event.
3. Confirm the workflow reports `handoff_started`.
4. Confirm the issue comment records `prompt_ref` and `.github/workflows/codex-spec-kit-agent.yml` as the downstream workflow.
5. Confirm the downstream reusable workflow receives `$speckit.specify <issue body>` as its command input exactly once.

## Invalid Issue Path

1. Open an issue with only a short or boilerplate body.
2. Confirm the workflow reports `skipped`.
3. Confirm the issue comment explains that the body lacked enough feature detail.
