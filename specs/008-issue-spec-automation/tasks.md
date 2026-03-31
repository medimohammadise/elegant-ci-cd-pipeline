# Tasks: Issue-Driven Spec Planning Workflow

**Input**: Design documents from `/specs/008-issue-spec-automation/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include workflow-focused contract and integration validation because intake correctness, downstream handoff timing, and duplicate prevention are core requirements.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the workflow files and validation documents shared across all stories.

- [X] T001 Create the intake workflow scaffold in `.github/workflows/issue-spec-automation.yml`
- [X] T002 [P] Refresh trigger and intake contract coverage in `tests/contract/issue-spec-automation-trigger.md`
- [X] T003 [P] Refresh trigger and intake integration coverage in `tests/integration/issue-spec-automation-trigger.md`
- [X] T004 [P] Update manual validation steps for the issue-created handoff flow in `specs/008-issue-spec-automation/quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared reusable-workflow contract, prompt structure, and outcome model before story-specific implementation.

- [X] T005 Define reusable workflow call expectations and outputs in `specs/008-issue-spec-automation/contracts/issue-spec-automation-workflow.md`
- [X] T006 [P] Align the downstream workflow interface in `.github/workflows/codex-spec-kit-agent.yml`
- [X] T007 [P] Define prompt reference, duplicate marker, and visible outcome fields in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: The intake workflow has a stable downstream-call contract and one shared outcome model for `handoff_started`, `skipped`, and `failed`.

---

## Phase 3: User Story 1 - Start feature definition from a new issue (Priority: P1) 🎯 MVP

**Goal**: A newly created eligible issue starts exactly one downstream planning handoff without manual intervention.

**Independent Test**: Open a valid issue and confirm `.github/workflows/issue-spec-automation.yml` runs from the `issues` `opened` event, validates the issue, and calls `codex-spec-kit-agent.yml` exactly once with `$speckit.specify <issue body>`.

### Tests for User Story 1

- [X] T008 [P] [US1] Add eligible-issue and insufficient-detail scenarios to `tests/contract/issue-spec-automation-trigger.md`
- [X] T009 [P] [US1] Add end-to-end issue-created scenarios to `tests/integration/issue-spec-automation-trigger.md`

### Implementation for User Story 1

- [X] T010 [US1] Configure `issues` `opened` and manual `workflow_dispatch` entrypoints in `.github/workflows/issue-spec-automation.yml`
- [X] T011 [US1] Implement issue metadata loading, body normalization, and eligibility validation in `.github/workflows/issue-spec-automation.yml`
- [X] T012 [US1] Implement the post-validation `$speckit.specify <issue body>` handoff input in `.github/workflows/issue-spec-automation.yml`
- [X] T013 [US1] Call `.github/workflows/codex-spec-kit-agent.yml` only after issue creation and intake checks succeed in `.github/workflows/issue-spec-automation.yml`
- [X] T014 [US1] Record visible `handoff_started`, `skipped`, and `failed` issue comments in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: Eligible issues reliably trigger one visible downstream planning handoff, and ineligible issues stop with a clear reason.

---

## Phase 4: User Story 2 - Generate spec, plan, and task artifacts from the issue description (Priority: P1)

**Goal**: The downstream Spec Kit workflow receives the right command input and preserves enough context for maintainers to trace generated artifacts back to the issue.

**Independent Test**: Process a valid issue and confirm the downstream workflow receives `$speckit.specify <issue body>`, then produces planning artifacts whose lineage is traceable from the originating issue.

### Tests for User Story 2

- [X] T015 [P] [US2] Add downstream handoff and artifact-traceability expectations to `tests/contract/issue-spec-artifacts.md`
- [X] T016 [P] [US2] Add downstream artifact-generation and traceability scenarios to `tests/integration/issue-spec-artifacts.md`

### Implementation for User Story 2

- [X] T017 [US2] Pass prompt input, originating issue context, and traceability fields through `.github/workflows/issue-spec-automation.yml`
- [X] T018 [US2] Expose downstream prompt handling and caller-facing outputs in `.github/workflows/codex-spec-kit-agent.yml`
- [X] T019 [US2] Ensure maintainer-visible handoff details include prompt reference and downstream workflow identification in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: The downstream planning workflow receives the correct issue-body prompt and maintainers can trace resulting planning artifacts back to the issue.

---

## Phase 5: User Story 3 - Prevent duplicate or conflicting planning runs (Priority: P2)

**Goal**: Repeated processing of the same issue never starts a second downstream handoff.

**Independent Test**: Re-run the workflow for an already processed issue and confirm it skips cleanly, preserves the original handoff marker, and does not call the downstream workflow again.

### Tests for User Story 3

- [X] T020 [P] [US3] Add duplicate-handoff rules to `tests/contract/issue-spec-duplicates.md`
- [X] T021 [P] [US3] Add repeated-run integration scenarios to `tests/integration/issue-spec-duplicates.md`

### Implementation for User Story 3

- [X] T022 [US3] Add issue-number-based concurrency and duplicate marker detection to `.github/workflows/issue-spec-automation.yml`
- [X] T023 [US3] Implement rerun-safe skip behavior and duplicate-specific messaging in `.github/workflows/issue-spec-automation.yml`
- [X] T024 [US3] Handle downstream call failures without leaving a false success marker in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: Duplicate issue processing is safely skipped and concurrent unrelated issues remain independent.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation updates that span all stories.

- [X] T025 [P] Add the issue-spec intake workflow to repository workflow documentation in `CLAUDE.md`
- [ ] T026 Run the full handoff validation flow in `specs/008-issue-spec-automation/quickstart.md`
- [X] T027 Review workflow messages for clarity across handoff-started, skipped, and failed outcomes in `.github/workflows/issue-spec-automation.yml`

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup can start immediately.
- Foundational work blocks all user stories.
- User Story 1 depends on the Foundational phase.
- User Story 2 depends on User Story 1 because artifact traceability builds on a working intake handoff.
- User Story 3 depends on User Story 1 because duplicate protection wraps the working handoff path.
- Polish follows all completed user stories.

### User Story Dependencies

- User Story 1 (P1) is the MVP and must land first.
- User Story 2 (P1) extends User Story 1 with traceable downstream artifact generation.
- User Story 3 (P2) can begin after User Story 1 and run in parallel with late User Story 2 validation once the core handoff path is stable.

### Within Each User Story

- Update story-specific contract and integration docs before or alongside implementation.
- Intake validation and prompt construction must exist before the downstream workflow call is wired.
- Duplicate handling must build on the final visible outcome format.

### Parallel Opportunities

- T002, T003, and T004 can run in parallel.
- T006 and T007 can run in parallel after T005.
- T008 and T009 can run in parallel.
- T015 and T016 can run in parallel.
- T020 and T021 can run in parallel.
- T025 and T026 can run in parallel during the final polish phase.

---

## Parallel Example: User Story 1

```bash
# After the foundational handoff contract is defined, these validation tasks can run in parallel:
Task T008: "Add eligible-issue and insufficient-detail scenarios to tests/contract/issue-spec-automation-trigger.md"
Task T009: "Add end-to-end issue-created scenarios to tests/integration/issue-spec-automation-trigger.md"
```

---

## Implementation Strategy

### MVP First

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate the issue-created handoff path before extending artifact traceability and duplicate protection.

### Incremental Delivery

1. Deliver the intake workflow and reusable-workflow call.
2. Add downstream traceability and artifact-facing visibility.
3. Add duplicate protection and polish the maintainer-facing experience.
