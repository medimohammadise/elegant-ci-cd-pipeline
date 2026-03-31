# Implementation Plan: Issue-Driven Spec Planning Workflow

**Branch**: `[008-issue-spec-automation]` | **Date**: 2026-03-31 | **Spec**: [/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/spec.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/spec.md)
**Input**: Feature specification from `/specs/008-issue-spec-automation/spec.md`

## Summary

Add an issue-intake GitHub Actions workflow that runs after a new issue is created, validates the issue body, prevents duplicate handoffs, and then calls `.github/workflows/codex-spec-kit-agent.yml` exactly once for eligible issues using the command `$speckit.specify <issue body>`. The intake workflow reports a visible issue outcome, while branch creation and Spec Kit artifact generation remain the responsibility of the downstream reusable workflow.

## Technical Context

**Language/Version**: YAML-based GitHub Actions workflows with inline JavaScript via `actions/github-script@v7` and shell validation scripts
**Primary Dependencies**: GitHub Actions reusable workflows, `actions/github-script@v7`, Codex CLI runner integration, Spec Kit bash helpers
**Storage**: GitHub issues/comments, workflow inputs/outputs, repository files under `specs/` and `tests/`
**Testing**: Contract and integration workflow documentation under `tests/contract/` and `tests/integration/`, plus YAML parsing and manual workflow validation
**Target Platform**: GitHub Actions on this repository with a reusable downstream workflow and self-hosted Codex runner
**Project Type**: Reusable workflow automation repository
**Performance Goals**: Produce a definitive intake outcome within a single workflow run and start the downstream handoff without manual intervention for eligible issues
**Constraints**: The intake workflow must not create branches directly, must call `codex-spec-kit-agent.yml` only after issue creation and intake checks succeed, and must avoid duplicate handoffs per issue
**Scale/Scope**: Repository-level automation for multiple independent issue-created runs, one primary handoff per issue

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The constitution file at `.specify/memory/constitution.md` is still a placeholder template, so no substantive project principles can be enforced yet. Current gate result: provisionally pass with documentation-only review, with the known governance gap recorded for future cleanup.

## Project Structure

### Documentation (this feature)

```text
specs/008-issue-spec-automation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── issue-spec-automation-workflow.md
└── tasks.md
```

### Source Code (repository root)

```text
.github/
└── workflows/
    ├── codex-spec-kit-agent.yml
    └── issue-spec-automation.yml

specs/
└── 008-issue-spec-automation/
    ├── contracts/
    ├── data-model.md
    ├── plan.md
    ├── quickstart.md
    ├── research.md
    ├── spec.md
    └── tasks.md

tests/
├── contract/
│   ├── issue-spec-artifacts.md
│   ├── issue-spec-automation-trigger.md
│   └── issue-spec-duplicates.md
└── integration/
    ├── issue-spec-artifacts.md
    ├── issue-spec-automation-trigger.md
    └── issue-spec-duplicates.md
```

**Structure Decision**: Keep implementation within the existing workflow-centric repository layout. Workflow behavior lives under `.github/workflows/`, while planning contracts and validation guidance remain under `specs/008-issue-spec-automation/` and `tests/`.

## Phase 0: Research

Completed in [/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/research.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/research.md).

Key decisions:
- Use the `issues` `opened` event as the primary intake trigger.
- Call `.github/workflows/codex-spec-kit-agent.yml` directly instead of using `repository_dispatch` or inline branch creation.
- Build the downstream command input as `$speckit.specify <normalized issue body>`.
- Use issue-level durable markers for idempotency and visible issue comments for operator-facing status.

## Phase 1: Design & Contracts

Artifacts:
- Data model: [/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/data-model.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/data-model.md)
- Workflow contract: [/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/contracts/issue-spec-automation-workflow.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/contracts/issue-spec-automation-workflow.md)
- Manual validation: [/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/quickstart.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/008-issue-spec-automation/quickstart.md)

Design focus:
- Intake evaluation loads issue metadata, normalizes the body, and determines eligibility.
- Duplicate prevention is keyed by issue identity and prior successful handoff marker.
- The reusable workflow call happens only after the issue exists and the intake checks pass.
- The handoff contract uses the exact command input `$speckit.specify <issue body>`.
- Visible issue comments communicate `handoff_started`, `skipped`, or `failed` without requiring Actions log inspection.
- Downstream artifact generation, including branch creation, remains outside the intake workflow.

## Phase 2: Implementation Preview

Expected implementation slices:
1. Update `.github/workflows/issue-spec-automation.yml` for trigger handling, eligibility checks, duplicate prevention, reusable-workflow handoff, and issue reporting.
2. Align `.github/workflows/codex-spec-kit-agent.yml` with caller inputs and outputs needed for the intake workflow.
3. Refresh contract, integration, and quickstart documentation to reflect direct reusable-workflow invocation and the `$speckit.specify <issue body>` handoff contract.

## Complexity Tracking

No constitution-driven complexity exceptions are currently identified.
