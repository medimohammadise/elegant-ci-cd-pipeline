# Quickstart: Issue-Driven Spec Planning Workflow

## Goal

Validate that a newly created issue can trigger a single downstream Spec Kit planning handoff through `codex-spec-kit-agent.yml` without duplicate intake.

## Manual Validation Steps

1. Create a repository issue with a title and body that clearly describe a new feature request.
2. Confirm `.github/workflows/issue-spec-automation.yml` starts automatically from the `issues` `opened` event.
3. Verify the workflow either:
   - calls `codex-spec-kit-agent.yml` with the command `$speckit.specify <issue body>`, or
   - skips with a clear duplicate or validation message.
4. Confirm the issue comment reports `handoff_started`, `skipped`, or `failed` with a human-readable explanation.
5. For a valid issue, confirm the recorded prompt reference identifies the downstream handoff.
6. Confirm the downstream Spec Kit workflow creates the planning artifacts:
   - `spec.md`
   - `plan.md`
   - `tasks.md`
   - `checklists/requirements.md`
7. Confirm the generated artifacts reference the originating issue.
8. Re-run the workflow for the same issue and verify that no duplicate downstream handoff is created.

## Expected Result

- Valid issues produce one coherent downstream planning handoff.
- Invalid issues are rejected with a clear reason.
- Repeated runs for the same issue do not create duplicate handoffs or duplicate planning artifacts.
