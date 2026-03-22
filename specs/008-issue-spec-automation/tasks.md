# Tasks: Issue-Driven Spec Planning Workflow

**Input**: Design documents from `/specs/008-issue-spec-automation/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Tests**: Include workflow-focused contract and integration validation because automation correctness and duplicate prevention are core requirements.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare workflow files and fixtures needed for issue-driven automation work.

- [ ] T001 Create the workflow scaffold in `.github/workflows/issue-spec-automation.yml`
- [ ] T002 Create reusable issue fixture files for workflow validation under `tests/contract/` and `tests/integration/`
- [ ] T003 [P] Document the generated artifact conventions for this feature in `specs/008-issue-spec-automation/quickstart.md` if implementation details change

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish shared issue parsing, duplicate detection, and artifact path resolution before user-story-specific behavior.

- [ ] T004 Define issue eligibility and missing-description handling in `.github/workflows/issue-spec-automation.yml`
- [ ] T005 [P] Define duplicate-detection rules tied to the originating issue in `.github/workflows/issue-spec-automation.yml`
- [ ] T006 [P] Define artifact metadata outputs for branch name, feature directory, and status reporting in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: Workflow can safely decide whether to create, skip, or fail before writing artifacts.

---

## Phase 3: User Story 1 - Start feature definition from a new issue (Priority: P1) 🎯 MVP

**Goal**: Trigger and validate the issue-created workflow so valid feature issues start a single planning run.

**Independent Test**: Open a valid issue fixture and confirm one run starts; open an invalid issue fixture and confirm the workflow exits with a clear validation reason.

### Tests for User Story 1

- [ ] T007 [P] [US1] Add contract coverage for issue-created trigger eligibility in `tests/contract/issue-spec-automation-trigger.md`
- [ ] T008 [P] [US1] Add integration coverage for valid and invalid issue intake flows in `tests/integration/issue-spec-automation-trigger.md`

### Implementation for User Story 1

- [ ] T009 [US1] Configure issue-created event handling and required permissions in `.github/workflows/issue-spec-automation.yml`
- [ ] T010 [US1] Implement issue description extraction and validation in `.github/workflows/issue-spec-automation.yml`
- [ ] T011 [US1] Implement human-readable skip and failure reporting for invalid issue bodies in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: New issues reliably start or stop the workflow with a clear decision.

---

## Phase 4: User Story 2 - Generate spec, plan, and task artifacts from the issue description (Priority: P1)

**Goal**: Produce a full feature artifact set from a valid issue.

**Independent Test**: Process a valid issue and confirm the workflow creates a feature branch plus `spec.md`, `plan.md`, `tasks.md`, and the requirements checklist in the generated feature directory.

### Tests for User Story 2

- [ ] T012 [P] [US2] Add contract coverage for issue-to-artifact traceability expectations in `tests/contract/issue-spec-artifacts.md`
- [ ] T013 [P] [US2] Add integration coverage for full artifact generation in `tests/integration/issue-spec-artifacts.md`

### Implementation for User Story 2

- [ ] T014 [US2] Invoke `.specify/scripts/bash/create-new-feature.sh` from `.github/workflows/issue-spec-automation.yml`
- [ ] T015 [US2] Generate `spec.md` content from issue data in `.github/workflows/issue-spec-automation.yml`
- [ ] T016 [US2] Invoke `.specify/scripts/bash/setup-plan.sh` and populate `plan.md` in `.github/workflows/issue-spec-automation.yml`
- [ ] T017 [US2] Generate `tasks.md` and `checklists/requirements.md` in `.github/workflows/issue-spec-automation.yml`
- [ ] T018 [US2] Record artifact references back to the originating issue in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: A valid issue produces one complete, traceable planning artifact set.

---

## Phase 5: User Story 3 - Prevent duplicate or conflicting planning runs (Priority: P2)

**Goal**: Ensure reruns and repeated processing for the same issue do not create conflicting artifacts.

**Independent Test**: Re-run the workflow for an already processed issue and confirm the result is a clean skip or reuse outcome with no duplicate branch or spec directory creation.

### Tests for User Story 3

- [ ] T019 [P] [US3] Add contract coverage for duplicate issue detection in `tests/contract/issue-spec-duplicates.md`
- [ ] T020 [P] [US3] Add integration coverage for repeated issue processing in `tests/integration/issue-spec-duplicates.md`

### Implementation for User Story 3

- [ ] T021 [US3] Implement duplicate artifact detection before generation in `.github/workflows/issue-spec-automation.yml`
- [ ] T022 [US3] Implement rerun-safe status reporting and skip behavior in `.github/workflows/issue-spec-automation.yml`
- [ ] T023 [US3] Handle partial-generation recovery paths in `.github/workflows/issue-spec-automation.yml`

**Checkpoint**: Repeated runs remain idempotent and understandable to maintainers.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improve maintainability and validate the complete workflow behavior.

- [ ] T024 [P] Add workflow usage notes to `docs/` or `README` if repository documentation exists for automation workflows
- [ ] T025 Run end-to-end validation using the steps in `specs/008-issue-spec-automation/quickstart.md`
- [ ] T026 Review generated messaging for clarity across success, skip, and failure outcomes

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup can start immediately.
- Foundational work blocks all user stories.
- User Stories 1 and 2 should be completed in order because artifact generation depends on valid intake handling.
- User Story 3 depends on the artifact-generation flow from User Story 2.
- Polish follows all completed user stories.

### Parallel Opportunities

- T002 and T003 can run in parallel after T001.
- T005 and T006 can run in parallel after T004.
- Test-writing tasks within each story marked `[P]` can run in parallel.
- Documentation cleanup and message review can run in parallel during Phase 6.

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational phases.
2. Deliver User Story 1 to validate issue intake.
3. Deliver User Story 2 to create the full artifact set.
4. Validate the generated branch and planning documents against the quickstart.

### Incremental Delivery

1. Establish deterministic workflow triggering and validation.
2. Add artifact generation and issue traceability.
3. Add duplicate prevention and recovery behavior.
4. Finish with documentation and end-to-end validation.
