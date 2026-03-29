# Contract Scenarios: Issue Spec Automation Trigger

## Purpose

Validate the external contract for issue-triggered intake and early workflow decisions.

## Scenarios

1. A newly opened issue with a non-empty feature body starts one automation run.
2. An issue body with insufficient feature detail produces `status = skipped`.
3. The workflow emits `status`, `message`, `prompt_ref`, `branch_name`, and `specs_dir` outputs for eligible issues.
4. The workflow publishes an issue comment containing the hidden `issue-spec-automation` marker and visible outcome fields.
5. The workflow records blocked dependent subtasks in the handoff payload without starting them.
