# Implementation Plan: Centralized GitHub Actions Version Management

**Branch**: `009-centralize-action-versions` | **Date**: 2026-03-29 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/009-centralize-action-versions/spec.md`

## Summary

Introduce a single version manifest file (`.github/actions-versions.yml`) as the source of truth for all external GitHub Actions versions used across this repository's workflow files. Enforce alignment via a bash drift-check script and a new CI workflow that gates pull requests modifying `.github/`.

Current state: 12 unique action references across 10 workflow files, already version-consistent (Dependabot recently bumped the group). The manifest will codify this state and prevent future drift.

## Technical Context

**Language/Version**: Bash (POSIX-compatible shell); YAML (manifest and workflow files)
**Primary Dependencies**: None beyond GitHub-hosted runner tooling (`grep`, `awk`, `sed` — all pre-installed)
**Storage**: File-based — `.github/actions-versions.yml` manifest; existing `.github/workflows/*.yml`
**Testing**: Manual `exit-code` validation + contract test documents in `tests/contract/`
**Target Platform**: GitHub Actions (ubuntu-latest runner)
**Project Type**: GitHub Actions workflow library (CI/CD tooling repo)
**Performance Goals**: Drift check completes in under 5 seconds on the current workflow inventory
**Constraints**: No external tool dependencies; script must run on a plain `ubuntu-latest` runner without extra setup steps
**Scale/Scope**: 10 workflow files, 12 distinct action references; expected slow growth (~1-2 new actions/quarter)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
| --------- | ------ | ----- |
| **Workflow file naming** (kebab-case, `ci-` prefix for CI) | PASS | New workflow named `ci-action-version-drift.yml` |
| **Keep workflows small and reusable** | PASS | Single-purpose CI check; no job bloat |
| **Use least-privilege permissions** | PASS | New workflow needs only `contents: read` |
| **Avoid duplication** | PASS | One manifest, one script — no duplicated version strings |
| **Prefer clarity over brevity** | PASS | Manifest uses full action names as keys; script output is human-readable |
| **Secrets naming** (UPPER_SNAKE_CASE) | N/A | No secrets required |
| **Environments** (lowercase only) | N/A | No environment deployment |
| **Docker rules** | N/A | No Docker involved |

**Post-design re-check**: All gates continue to pass. No constitution violations.

## Project Structure

### Documentation (this feature)

```text
specs/009-centralize-action-versions/
├── plan.md              ← this file
├── spec.md
├── research.md          ← Phase 0: decisions on approach, format, tooling
├── data-model.md        ← Phase 1: manifest schema, drift report format
├── quickstart.md        ← Phase 1: day-to-day usage guide
├── contracts/
│   └── drift-check-script.md   ← CLI + CI workflow interface contract
└── tasks.md             ← Phase 2 output (/speckit.tasks — not yet created)
```

### Source Code (repository root)

```text
.github/
├── actions-versions.yml          ← NEW: version manifest (source of truth)
└── workflows/
    ├── ci-action-version-drift.yml  ← NEW: CI drift-check workflow
    └── (existing workflows — no changes to their uses: lines)

.specify/scripts/bash/
└── check-action-versions.sh      ← NEW: drift-check script

tests/
├── contract/
│   └── ci-action-version-drift.md  ← NEW: CI workflow interface contract doc
└── integration/
    └── action-version-drift.md     ← NEW: end-to-end scenario assertions
```

**Structure Decision**: Files follow the repo's established conventions — scripts in `.specify/scripts/bash/`, new CI workflows alongside existing ones in `.github/workflows/`, test contract documents in `tests/contract/` and `tests/integration/`.

## Complexity Tracking

No constitution violations. Section not applicable.

---

## Phase 0: Research Findings

→ See [`research.md`](./research.md) for full decision records.

**Key decisions**:
1. **Manifest as YAML file** at `.github/actions-versions.yml` — flat `actions:` map, no nesting
2. **Bash-only drift check** — no `yq` or Python; uses `grep`/`awk` for portability across all GitHub-hosted runners
3. **New `ci-action-version-drift.yml` workflow** — triggers on `pull_request` for `.github/**`
4. **Dependabot integration (v1: manual)** — maintainer updates manifest in the same PR as a Dependabot bump; automated manifest sync is a follow-on
5. **Local workflow refs excluded** — `uses: ./.github/workflows/...` lines are skipped by the drift check

---

## Phase 1: Design Artifacts

→ See [`data-model.md`](./data-model.md) for schema details.
→ See [`contracts/drift-check-script.md`](./contracts/drift-check-script.md) for CLI + CI workflow interface.
→ See [`quickstart.md`](./quickstart.md) for day-to-day usage.

**Manifest initial state** (all 12 current action references):

| Action | Approved Version |
| ------ | ---------------- |
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

## Implementation Sequence

Tasks will be generated by `/speckit.tasks`. Logical sequence:

1. **Create manifest file** — `.github/actions-versions.yml` with all 12 current entries
2. **Create drift-check script** — `.specify/scripts/bash/check-action-versions.sh`
3. **Create CI workflow** — `.github/workflows/ci-action-version-drift.yml`
4. **Create test contract doc** — `tests/contract/ci-action-version-drift.md`
5. **Create integration scenario doc** — `tests/integration/action-version-drift.md`
6. **Validate end-to-end** — run drift check locally; confirm PASS on clean repo and FAIL on introduced mismatch

Each step is independently deliverable. Step 1 alone provides the reference document. Steps 1+2 enable local validation. Adding step 3 closes the CI enforcement gate.
