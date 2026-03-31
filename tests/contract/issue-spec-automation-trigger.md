# Contract Scenarios: Issue Spec Automation Trigger

## Purpose

Validate the external contract for issue-triggered intake and early workflow decisions.

## Scenarios

1. A newly opened issue with sufficient feature detail starts one automation run and prepares the command input `$speckit.specify <issue body>`.
2. An issue body with insufficient feature detail produces `status = skipped`.
3. The workflow records `status`, `message`, `prompt_ref`, and the downstream workflow path for eligible issues.
4. The workflow publishes an issue comment containing the hidden `issue-spec-automation` marker only after a successful downstream handoff start.
5. The workflow supports `workflow_dispatch` for a specific issue number during manual validation.
