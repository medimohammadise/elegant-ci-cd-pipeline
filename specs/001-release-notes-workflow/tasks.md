# Tasks: Reusable Release Notes and Version Automation

**Input**: Design documents from `/specs/001-release-notes-workflow/`
**Prerequisites**: [plan.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/001-release-notes-workflow/plan.md), [spec.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/001-release-notes-workflow/spec.md), [research.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/001-release-notes-workflow/research.md), [data-model.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/001-release-notes-workflow/data-model.md), [reusable-release-workflow.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/001-release-notes-workflow/contracts/reusable-release-workflow.md), [quickstart.md](/Users/mehdi/MyProject/elegant-ci-cd-pipeline/specs/001-release-notes-workflow/quickstart.md)

**Tests**: Conventional application test cases are not assumed for this feature. Validation should be scenario-based and workflow-focused.

**Organization**: Tasks are grouped by user story to enable independent implementation and validation of each story while keeping the final output as a reusable GitHub Actions workflow for release notes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the workflow, documentation, and validation file layout for a reusable GitHub Actions release-notes feature.

- [X] T001 Create the reusable workflow file scaffold in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml
- [X] T002 [P] Create the consumer documentation scaffold in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/docs/reusable-release-notes.md
- [X] T003 [P] Create the release policy reference scaffold in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/docs/release-policy.md
- [X] T004 [P] Create the contract validation index in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/contract/reusable-release-workflow/README.md
- [X] T005 [P] Create the integration scenario index in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/integration/release-history-scenarios/README.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define the reusable workflow contract, shared policy surface, and baseline validation assets that all user stories depend on.

**⚠️ CRITICAL**: No user story work should start until this phase is complete.

- [X] T006 Define the `workflow_call` entrypoint, shared inputs, and shared outputs in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml
- [X] T007 [P] Document the callable input/output contract in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/contract/reusable-release-workflow/workflow-call-contract.md
- [X] T008 [P] Record baseline release-history fixtures and expected outcomes in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/integration/release-history-scenarios/baseline-scenarios.md
- [X] T009 Define category rules, version rules, fallback rules, and revert policy in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/docs/release-policy.md

**Checkpoint**: Foundation ready; the reusable workflow contract and policy surface are defined.

---

## Phase 3: User Story 1 - Publish consistent release summaries (Priority: P1) 🎯 MVP

**Goal**: Generate categorized release notes from merged pull request metadata through the reusable workflow.

**Independent Test**: Run the workflow against fixture histories that contain categorized and unlabeled pull requests and confirm that the output groups included changes into the expected release-note sections with a deterministic fallback section.

- [X] T010 [US1] Implement pull request collection, release-note section grouping, and markdown/json release-note outputs in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml
- [X] T011 [P] [US1] Add categorized and unlabeled release-note scenarios in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/integration/release-history-scenarios/us1-release-notes.md
- [X] T012 [P] [US1] Document release-note output examples and section ordering in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/contract/reusable-release-workflow/release-notes-output.md
- [X] T013 [US1] Document release-note categories, fallback behavior, and consumer-visible outputs in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/docs/reusable-release-notes.md

**Checkpoint**: User Story 1 delivers an independently usable reusable workflow for generating release notes.

---

## Phase 4: User Story 2 - Determine the correct semantic version bump (Priority: P1)

**Goal**: Compute the highest required semantic version bump from eligible merged pull requests since the release boundary.

**Independent Test**: Run the workflow against fixture histories for patch-only, minor-inclusive, major-inclusive, conflicting, reverted, and empty-release cases and confirm that the selected version outcome matches the expected semantic decision.

- [X] T014 [US2] Implement release boundary resolution and highest-precedence semantic version selection in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml
- [X] T015 [US2] Implement conflicting-metadata failures, reverted-pull-request exclusion, and `no releasable changes` handling in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml
- [X] T016 [P] [US2] Add semantic version decision scenarios in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/integration/release-history-scenarios/us2-versioning.md
- [X] T017 [P] [US2] Document version outputs, failure messages, and no-release outcomes in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/contract/reusable-release-workflow/version-decision-output.md

**Checkpoint**: User Stories 1 and 2 together provide reusable release-note generation plus automatic version selection.

---

## Phase 5: User Story 3 - Reuse the automation across repositories (Priority: P2)

**Goal**: Make the workflow straightforward to call from multiple repositories with stable inputs, outputs, and consumer guidance.

**Independent Test**: Review the reusable workflow contract and consumer guidance against multiple repository scenarios and confirm that the same callable interface supports consistent behavior without repository-local helper scripts.

- [X] T018 [US3] Finalize reusable consumer inputs, outputs, and handoff fields in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml
- [X] T019 [P] [US3] Add consumer invocation guidance and example usage for calling repositories in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/docs/reusable-release-notes.md
- [X] T020 [P] [US3] Add multi-repository adoption scenarios in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/integration/release-history-scenarios/us3-reuse.md
- [X] T021 [P] [US3] Align the final reusable contract details with consumer expectations in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/contract/reusable-release-workflow/workflow-call-contract.md

**Checkpoint**: All user stories are complete, and the deliverable is a reusable GitHub Actions workflow for release notes.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency, validation guidance, and release-readiness cleanup across the whole feature.

- [X] T022 [P] Reconcile final policy wording, label taxonomy, and fallback rules in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/docs/release-policy.md
- [X] T023 [P] Record quickstart validation steps and dry-run expectations in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/tests/integration/release-history-scenarios/quickstart-validation.md
- [X] T024 Run quickstart alignment and finalize workflow output names and failure messaging in /Users/mehdi/MyProject/elegant-ci-cd-pipeline/.github/workflows/reusable-release-notes.yml

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** has no dependencies and can start immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks all user story work.
- **Phase 3: User Story 1** depends on Phase 2 and delivers the MVP reusable release-notes workflow.
- **Phase 4: User Story 2** depends on User Story 1 because both extend the same workflow file and versioning builds directly on the release-candidate logic.
- **Phase 5: User Story 3** depends on User Stories 1 and 2 because reusable consumer guidance must reflect the final callable workflow behavior.
- **Phase 6: Polish** depends on all desired user stories being complete.

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational and has no dependency on other user stories.
- **US2 (P1)**: Starts after US1 because it extends the same workflow source and relies on release-candidate outputs from US1.
- **US3 (P2)**: Starts after US1 and US2 because it finalizes the reusable interface and consumer guidance for the completed workflow.

### Parallel Opportunities

- `T002`, `T003`, `T004`, and `T005` can run in parallel during setup.
- `T007` and `T008` can run in parallel after `T006` defines the shared workflow surface.
- `T011` and `T012` can run in parallel after `T010`.
- `T016` and `T017` can run in parallel after `T014` and `T015`.
- `T019`, `T020`, and `T021` can run in parallel after `T018`.
- `T022` and `T023` can run in parallel during polish before `T024`.

---

## Parallel Example: User Story 1

```bash
# After T010 completes, run the release-note validation artifacts in parallel:
Task: "Add categorized and unlabeled release-note scenarios in tests/integration/release-history-scenarios/us1-release-notes.md"
Task: "Document release-note output examples and section ordering in tests/contract/reusable-release-workflow/release-notes-output.md"
```

## Parallel Example: User Story 3

```bash
# After T018 completes, finish the reusable adoption artifacts in parallel:
Task: "Add consumer invocation guidance and example usage for calling repositories in docs/reusable-release-notes.md"
Task: "Add multi-repository adoption scenarios in tests/integration/release-history-scenarios/us3-reuse.md"
Task: "Align the final reusable contract details with consumer expectations in tests/contract/reusable-release-workflow/workflow-call-contract.md"
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Stop and validate the reusable release-note generation flow with the US1 scenario artifacts.

### Incremental Delivery

1. Deliver the reusable release-note workflow surface and grouped notes first through US1.
2. Add semantic version decision logic through US2.
3. Finalize multi-repository reusability and consumer guidance through US3.
4. Finish with polish and quickstart validation.

### Suggested MVP Scope

The smallest valuable increment is **User Story 1**: a reusable GitHub Actions workflow that generates categorized release notes from merged pull requests and exposes those notes as outputs.

## Notes

- Conventional application test-case tasks were intentionally omitted because this feature is GitHub Actions workflow source code.
- Validation tasks are expressed as contract artifacts, scenario fixtures, and quickstart checks to match the planned workflow-focused verification strategy.
- All tasks use the required checklist format with IDs, labels where applicable, and exact file paths.
