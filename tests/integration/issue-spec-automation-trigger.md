# Integration Scenarios: Issue Spec Automation Trigger

## Goal

Verify the highest-priority intake flow from issue creation through Codex handoff dispatch.

## Happy Path

1. Open a repository issue with a descriptive feature request body.
2. Confirm `.github/workflows/issue-spec-automation.yml` starts automatically from the `issues` `opened` event.
3. Confirm the workflow reports `handoff_started`.
4. Confirm the issue comment records `prompt_ref`, target branch, and target specs directory.
5. Confirm the downstream Codex pipeline receives one `repository_dispatch` event with the prompt package payload.

## Invalid Issue Path

1. Open an issue with only a short or boilerplate body.
2. Confirm the workflow reports `skipped`.
3. Confirm the issue comment explains that the body lacked enough feature detail.

## Deferred Subtask Observation

1. Open an issue that includes lines formatted as `- [subtask] ...` or `- [subtask:owner/repo] ...`.
2. Confirm the workflow reports those subtasks as blocked in the prompt payload.
3. Confirm no subtask dispatch is attempted before the primary handoff succeeds.
