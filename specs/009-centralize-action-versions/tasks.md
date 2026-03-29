# Tasks: Centralized GitHub Actions Version Management

**Input**: Design documents from `specs/009-centralize-action-versions/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Tests**: Contract and integration documents are living-spec test docs (not executable), consistent with the repo's existing `tests/contract/` and `tests/integration/` conventions.

**Organization**: Tasks are grouped by user story to enable independent implementation and validation of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Path Conventions

This repo has no `src/` tree. All deliverables live under:
- `.github/` — workflow files and manifest
- `.specify/scripts/bash/` — shell scripts
- `tests/contract/` and `tests/integration/` — living-spec test documents

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the version manifest that serves as the source of truth for all subsequent phases.

- [x] T001 Create `.github/actions-versions.yml` with all 12 current action entries, a file-level comment explaining its purpose, and an initial `description:` annotation for each entry

**Manifest entries to include** (verified from current workflow scan):

| Action | Version |
| ------ | ------- |
| `actions/checkout` | `v6` |
| `actions/setup-java` | `v5` |
| `actions/github-script` | `v8` |
| `actions/upload-artifact` | `v7` |
| `actions/attest-build-provenance` | `v4` |
| `docker/setup-buildx-action` | `v4` |
| `docker/login-action` | `v4` |
| `docker/metadata-action` | `v6` |
| `docker/build-push-action` | `v7` |
| `gradle/actions/setup-gradle` | `v6` |
| `peter-evans/create-pull-request` | `v8` |
| `JetBrains/qodana-action` | `v2025.3.2` |

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: T001 (Phase 1) is the sole prerequisite for all user stories. No additional blocking work.

**⚠️ CRITICAL**: T001 must be complete before Phase 3 and Phase 4 begin.

---

## Phase 3: User Story 1 — Single-Place Version Update (Priority: P1) 🎯 MVP

**Goal**: A maintainer can determine the project-approved version for any action by reading one file, and updating that file documents the version decision for the whole project.

**Independent Test**: Run `grep -h "uses:" .github/workflows/*.yml | grep -v "\.github/workflows" | grep "@" | sed 's/.*uses: //' | sort -u` — every `owner/action@version` token in the output must have a matching entry in `.github/actions-versions.yml` at the same version.

### Implementation for User Story 1

- [x] T002 [US1] Verify manifest completeness: run the grep command above against the current workflow directory and confirm every external `uses:` reference appears in `.github/actions-versions.yml` at the correct version; fix any gaps found
- [x] T003 [P] [US1] Create `tests/contract/ci-action-version-drift.md` — document the expected interface of the drift-check CI workflow (triggers, permissions, inputs, outputs, exit conditions) following the repo's existing contract test doc format

**Checkpoint**: At this point, US1 is fully deliverable. The manifest exists and is complete. Any maintainer can open `.github/actions-versions.yml` to see the approved version for every action in use.

---

## Phase 4: User Story 2 — Drift Detection CI Gate (Priority: P2)

**Goal**: A CI check on every pull request that touches `.github/` catches any action version in a workflow file that does not match the manifest, and fails the PR until resolved.

**Independent Test**: (a) Introduce a deliberate version mismatch in any workflow file (e.g., change `actions/checkout@v6` to `actions/checkout@v4`), run `.specify/scripts/bash/check-action-versions.sh --strict`, and confirm exit code `1` with a report identifying the file, line, action, found version, and expected version. (b) Revert the mismatch, re-run, and confirm exit code `0`.

### Implementation for User Story 2

- [x] T004 [US2] Create `.specify/scripts/bash/check-action-versions.sh` implementing the drift-check logic per `specs/009-centralize-action-versions/contracts/drift-check-script.md`:
  - Parse `.github/actions-versions.yml` using `grep`/`awk` (no `yq` dependency)
  - Scan all `.github/workflows/*.yml` files for `uses:` lines
  - Skip local refs (`uses: ./.github/workflows/`)
  - For each external ref, compare `owner/action` key and `@version` against manifest
  - Report mismatches and unregistered actions to stdout in the format defined in `data-model.md`
  - Exit `0` on clean, `1` on mismatch/unregistered (with `--strict`), `2` on manifest not found
  - Make script executable (`chmod +x`)

- [x] T005 [US2] Create `.github/workflows/ci-action-version-drift.yml` per the contract in `specs/009-centralize-action-versions/contracts/drift-check-script.md`:
  - Trigger: `pull_request` on paths `.github/**`; also `workflow_dispatch`
  - Permissions: `contents: read` (least privilege)
  - Single job: checkout repo, run `.specify/scripts/bash/check-action-versions.sh --strict`
  - Write drift report to `$GITHUB_STEP_SUMMARY` on failure
  - Follow repo naming conventions (kebab-case, `ci-` prefix)

- [x] T006 [P] [US2] Validate the drift check end-to-end:
  - Introduce a test mismatch in a workflow file
  - Run `bash .specify/scripts/bash/check-action-versions.sh --strict`
  - Confirm exit code `1` and correct report format
  - Revert the mismatch
  - Run again and confirm exit code `0`
  - Document outcome in a comment or commit message

- [x] T007 [P] [US2] Create `tests/integration/action-version-drift.md` documenting the end-to-end scenario: Dependabot bumps workflow files without manifest update → CI fails → maintainer updates manifest → CI passes → merge

**Checkpoint**: At this point, US2 is fully deliverable. The CI drift check runs on every qualifying PR and blocks merges when versions are out of sync.

---

## Phase 5: User Story 3 — Onboarding Reference (Priority: P3)

**Goal**: A contributor can identify the project-approved version for any in-use action in under 30 seconds by opening a single, self-documenting file.

**Independent Test**: Open `.github/actions-versions.yml` alone (no other files). Every external action used in the project should be listed with its approved version and a brief purpose note — no cross-referencing needed.

### Implementation for User Story 3

- [x] T008 [US3] Add a `CONTRIBUTING` section to the top-level comment block in `.github/actions-versions.yml` explaining: (a) this file is the single source of truth for action versions, (b) how to add a new action, (c) how to handle Dependabot bump PRs, (d) how to run the drift check locally — referencing `specs/009-centralize-action-versions/quickstart.md` as the detailed guide

**Checkpoint**: At this point, US3 is fully deliverable. A new contributor can open the manifest, understand all approved versions, read onboarding notes, and know how to add a new action — without consulting any other file.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation updates that span all user stories.

- [x] T009 [P] Update the **Workflow Inventory** table in `CLAUDE.md` to add a row for `ci-action-version-drift.yml` with its purpose ("Validate all workflow action versions match `.github/actions-versions.yml`")
- [x] T010 Run the full quickstart.md validation sequence end-to-end on the local repo to confirm the feature works as described: check aligned state, introduce mismatch, catch it, resolve it, re-confirm clean

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately with T001
- **Foundational (Phase 2)**: Skipped — T001 is the sole prereq; covered by Phase 1
- **US1 (Phase 3)**: Depends on T001 (manifest must exist before completeness can be verified)
- **US2 (Phase 4)**: Depends on T001 (manifest must exist before the script can read it)
- **US3 (Phase 5)**: Depends on T001 (manifest must exist before onboarding comments can be added)
- **Polish (Phase 6)**: Depends on T005 (CI workflow must exist before CLAUDE.md can reference it)

### User Story Dependencies

- **US1 (P1)**: Depends only on T001 — can start immediately after Phase 1
- **US2 (P2)**: Depends only on T001 — can start immediately after Phase 1 (parallel with US1)
- **US3 (P3)**: Depends only on T001 — can start immediately after Phase 1 (parallel with US1 and US2)

### Within Each User Story

- US1: T001 → T002 → T003 (T003 is parallel once T001 is done)
- US2: T001 → T004 → T005 → T006, T007 (T006 and T007 are parallel after T005)
- US3: T001 → T008

### Parallel Opportunities

- T003 and T004 can run in parallel (different files, both depend only on T001)
- T006 and T007 can run in parallel (T006 = manual validation, T007 = doc writing)
- T009 and T010 can run in parallel (different files/activities)

---

## Parallel Example: US2

```bash
# After T004 and T005 are complete, launch these in parallel:
Task T006: "Validate drift check end-to-end (introduce mismatch, check exit codes, revert)"
Task T007: "Create tests/integration/action-version-drift.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: T001 — create the manifest
2. Complete Phase 3: T002 (verify completeness), T003 (contract doc)
3. **STOP and VALIDATE**: Open `.github/actions-versions.yml` — does it list all 12 actions at current versions? Can you identify the approved version for any action in under 30 seconds?
4. Ship: the manifest alone is a useful artifact even without the CI check

### Incremental Delivery

1. T001 → manifest exists → US1 satisfied (maintainer reference)
2. T001 → T004 → T005 → CI gate active → US2 satisfied (drift enforcement)
3. T001 → T008 → manifest is self-documenting → US3 satisfied (onboarding)
4. T009, T010 → polish complete

### Single-Developer Sequence (Recommended)

```
T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008 → T009 → T010
```

Total tasks: **10**

---

## Notes

- [P] tasks = different files, no blocking dependencies between them
- [Story] label maps each task to a specific user story for traceability
- No TDD requested — contract and integration test docs follow living-spec format
- The script (T004) must NOT require `yq` or any tool beyond `grep`/`awk`/`sed` — it must run on a plain `ubuntu-latest` runner with no setup step
- When validating (T006), revert the test mismatch before committing
- Commit after each logical group; semantic prefix: `feat:` for T001/T004/T005, `docs:` for T003/T007/T008/T009, `chore:` for T002/T006/T010
