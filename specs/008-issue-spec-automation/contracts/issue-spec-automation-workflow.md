# Contract: Issue Spec Automation Workflow

## Purpose

Define the externally visible workflow behavior for issue-driven Spec Kit planning handoff in this repository.

## Responsibilities

The workflow is responsible for:
- Starting when a repository issue is opened
- Reading issue metadata and body content as the planning source
- Determining whether the issue has enough feature detail to proceed
- Building the command input `$speckit.specify <issue body>`
- Preventing duplicate handoffs for the same originating issue
- Calling `codex-spec-kit-agent.yml` for eligible issues
- Reporting a clear `handoff_started`, `skipped`, or `failed` outcome in the issue thread

The workflow is not responsible for:
- Implementing the feature described by the issue
- Creating the feature branch directly inside the issue-opened workflow
- Generating the final planning artifacts inline within the issue-opened workflow
- Re-planning every subsequent issue edit automatically

## Trigger Contract

| Trigger | Required | Description |
|---------|----------|-------------|
| `issues` `opened` | Yes | Starts one planning evaluation for a newly created issue. |
| `workflow_dispatch` | No | Supports manual validation for a specific issue number. |

## Intake Fields

| Field | Required | Description |
|-------|----------|-------------|
| `issue.number` | Yes | Stable issue identifier used for idempotency and traceability. |
| `issue.title` | Yes | Human-readable feature title retained for downstream artifact context. |
| `issue.body` | Yes | Source description used to determine eligibility and to populate the downstream `$speckit.specify` prompt body. |
| `issue.html_url` | Yes | Canonical issue URL preserved for traceability. |
| `issue.created_at` | Yes | Issue creation timestamp used for auditability. |

## Downstream Workflow Call

| Field | Required | Description |
|-------|----------|-------------|
| `workflow` | Yes | `.github/workflows/codex-spec-kit-agent.yml` |
| `prompt` | Yes | `$speckit.specify <normalized issue body>` |
| `originating_issue_number` | Yes | Stable issue identifier retained for traceability. |
| `prompt_ref` | Yes | Unique handoff identifier for one issue-processing attempt. |

## Outputs

| Output | Description |
|--------|-------------|
| `status` | One of `handoff_started`, `skipped`, or `failed`. |
| `message` | Human-readable explanation of the workflow result. |
| `prompt_ref` | Handoff identifier when applicable. |
| `downstream_workflow` | Workflow path used for the handoff when applicable. |
| `issue_comment_ref` | Issue comment reference recording the visible outcome. |

## Behavioral Rules

1. The workflow must not call `codex-spec-kit-agent.yml` if the issue body lacks enough detail to produce a reliable specification.
2. The workflow must create at most one primary handoff to `codex-spec-kit-agent.yml` per originating issue.
3. Repeated runs for the same issue must return a skip outcome instead of creating a second handoff.
4. The workflow must not create a feature branch directly; branch creation belongs to the downstream Spec Kit workflow.
5. The workflow must pass the issue body to `codex-spec-kit-agent.yml` as the command input `$speckit.specify <issue body>`.
6. If the downstream workflow call fails, the visible outcome must clearly identify that failure stage.
7. Separate issues opened close together must be processed independently.
8. Generated artifacts must preserve a reference back to the originating issue number and URL.

## Validation Scenarios

- A valid feature issue produces one call to `codex-spec-kit-agent.yml`.
- A valid feature issue passes `$speckit.specify <issue body>` as the downstream command input.
- An issue with insufficient body detail is skipped with an explanatory message.
- A rerun for an already processed issue does not create a second downstream workflow call.
- A handoff failure reports that the reusable workflow was not successfully started.
- Two different valid issues can trigger separate downstream handoffs without collision.
