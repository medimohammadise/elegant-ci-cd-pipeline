# Contract: Issue Spec Automation Workflow

## Purpose

Define the externally visible workflow behavior for issue-driven Spec Kit artifact generation in this repository.

## Responsibilities

The workflow is responsible for:
- Starting when a repository issue is opened
- Reading issue metadata and body content as the planning source
- Determining whether the issue has enough feature detail to proceed
- Preparing a prompt package for the standalone Codex pipeline
- Preventing duplicate handoffs or artifact generation for the same originating issue
- Invoking the standalone Codex agent pipeline for eligible issues
- Deferring dependent subtasks until the primary issue handoff has completed successfully
- Reporting a clear handoff-started, skipped, or failed outcome

The workflow is not responsible for:
- Implementing the feature described by the issue
- Generating the final planning artifacts inline within the issue-triggered workflow
- Merging or approving generated planning artifacts
- Re-planning every subsequent issue edit automatically

## Trigger Contract

| Trigger | Required | Description |
|---------|----------|-------------|
| `issues` `opened` | Yes | Starts one planning evaluation for a newly created issue. |

## Intake Fields

| Field | Required | Description |
|-------|----------|-------------|
| `issue.number` | Yes | Stable issue identifier used for idempotency and traceability. |
| `issue.title` | Yes | Human-readable feature title used in generated artifacts. |
| `issue.body` | Yes | Source description used to determine eligibility and derive the generated spec. |
| `issue.html_url` | Yes | Canonical issue URL stored or echoed in generated outputs. |
| `issue.created_at` | Yes | Issue creation timestamp used for auditability. |

## Prompt Package

| Field | Required | Description |
|-------|----------|-------------|
| `prompt_id` | Yes | Unique handoff identifier for one issue-processing attempt. |
| `issue_number` | Yes | Originating issue number carried into the Codex pipeline. |
| `issue_title` | Yes | Issue title included in the prompt. |
| `issue_body` | Yes | Normalized issue description included in the prompt. |
| `issue_url` | Yes | Traceability link included in the prompt. |
| `instructions` | Yes | Explicit guidance directing the Codex pipeline to produce Spec Kit-compliant planning artifacts. |

## Dependent Subtasks

| Field | Required | Description |
|-------|----------|-------------|
| `subtask_id` | Yes | Unique identifier for the dependent subtask. |
| `primary_issue_number` | Yes | Primary issue that must complete before the subtask can start. |
| `target_repository` | Yes | Repository where the subtask should be planned. |
| `dependency_status` | Yes | One of `blocked`, `ready`, `started`, `skipped`, or `failed`. |
| `dependency_reason` | No | Human-readable explanation for the current dependency state. |

## Outputs

| Output | Description |
|--------|-------------|
| `status` | One of `handoff_started`, `skipped`, or `failed`. |
| `message` | Human-readable explanation of the workflow result. |
| `prompt_ref` | Prompt package reference or handoff identifier when applicable. |
| `branch_name` | Generated or reused feature branch name when returned by the Codex pipeline. |
| `specs_dir` | Generated or reused feature directory path when applicable. |
| `spec_path` | Path to the generated specification when applicable. |
| `plan_path` | Path to the generated implementation plan when applicable. |
| `tasks_path` | Path to the generated task list when applicable. |
| `dependent_subtask_refs` | Dependent subtasks deferred, started, or skipped by the run. |

## Behavioral Rules

1. The workflow must not prepare or dispatch a prompt package if the issue body lacks enough detail to produce a reliable specification.
2. The workflow must create at most one primary prompt handoff and one primary artifact set per originating issue.
3. Repeated runs for the same issue must return a skip or reuse outcome instead of creating a second handoff, branch, or spec directory.
4. If the handoff to the Codex pipeline fails, the outcome must clearly identify that failure stage.
5. If generation fails after the Codex pipeline starts, the outcome must clearly identify failure rather than pretending the run succeeded.
6. Separate issues opened close together must be processed independently.
7. Generated artifacts must preserve a reference back to the originating issue number and URL.
8. Dependent subtasks must remain blocked until the primary issue reaches a successful handoff outcome.
9. Same-repo and cross-repo dependent subtasks must both preserve their target repository and primary-issue dependency in the recorded handoff context.

## Validation Scenarios

- A valid feature issue produces one prompt package and one Codex pipeline invocation.
- A valid feature issue creates a branch and populated `spec.md`, `plan.md`, and `tasks.md`.
- An issue with insufficient body detail is skipped with an explanatory message.
- A rerun for an already processed issue does not create duplicate handoffs or artifacts.
- A handoff failure reports that the Codex pipeline was not successfully invoked.
- A partial failure reports which stage failed and which artifacts, if any, were created.
- Two different valid issues can generate separate artifact sets without collision.
- Dependent subtasks remain blocked when the primary issue is skipped or fails.
- A dependent subtask targeting another repository retains the target repository in its handoff metadata.
