# Quickstart: Issue-Driven Spec Planning Workflow

## Goal

Validate that a newly created issue can trigger artifact generation and produce a specification, plan, and task list without duplication.

## Manual Validation Steps

1. Create a repository issue with a title and body that clearly describe a new feature request.
2. Confirm the issue-triggered workflow starts automatically.
3. Verify the workflow either:
   - creates a new feature branch and `specs/<feature>/` directory, or
   - skips with a clear duplicate or validation message.
4. If artifacts are created, confirm the feature directory contains:
   - `spec.md`
   - `plan.md`
   - `tasks.md`
   - `checklists/requirements.md`
5. Confirm the generated artifacts reference the originating issue.
6. Re-run the workflow for the same issue and verify that no duplicate branch or spec directory is created.

## Expected Result

- Valid issues produce one coherent artifact set.
- Invalid issues are rejected with a clear reason.
- Repeated runs for the same issue do not create duplicate planning artifacts.
