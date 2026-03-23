# Implementation Plan: Reusable Container Image Build Workflow

**Branch**: `[004-docker-build-workflow]` | **Date**: 2026-03-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-docker-build-workflow/spec.md`

## Summary

Add a reusable GitHub Actions workflow that builds a Spring Boot application into a container image through exactly one selected strategy per run, supporting both Dockerfile-based builds and Spring Boot buildpacks while returning stable success, failure, and image metadata outputs for downstream automation.

## Technical Context

**Language/Version**: YAML-based GitHub Actions workflows with shell scripting  
**Primary Dependencies**: GitHub Actions reusable workflows, Docker Buildx for Dockerfile builds, Gradle/Maven Spring Boot `bootBuildImage` support for buildpack builds  
**Storage**: Repository source tree, workflow inputs and outputs, and runner-local container build state  
**Testing**: Contract-style workflow interface checks, integration scenarios for both strategies, and dry-run validation against representative Spring Boot repository fixtures  
**Target Platform**: GitHub-hosted Linux runners  
**Project Type**: Reusable CI/CD workflow repository  
**Performance Goals**: Complete a valid container build within a single workflow execution and expose deterministic outputs immediately after build completion  
**Constraints**: Must choose exactly one strategy per run, avoid repository-local helper scripts, fail clearly on missing prerequisites, and expose outputs safe for downstream publish or deploy workflows  
**Scale/Scope**: Shared workflow intended for repeated reuse across Spring Boot repositories needing a common image-build entrypoint

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The repository constitution file remains an unfilled template and does not currently impose enforceable engineering, testing, or governance requirements.

- Pre-Phase 0 gate status: PASS. No actionable constitutional requirements are defined.
- Post-Phase 1 gate status: PASS. The planned workflow, documentation, and validation assets do not conflict with any stated constitutional rule.

## Project Structure

### Documentation (this feature)

```text
specs/004-docker-build-workflow/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── reusable-container-build-workflow.md
└── tasks.md
```

### Source Code (repository root)

```text
.github/
└── workflows/
    └── reusable-container-build.yml

docs/
└── reusable-container-build.md

tests/
├── contract/
│   └── reusable-container-build-workflow/
└── integration/
    └── container-build-scenarios/

specs/
└── 004-docker-build-workflow/
```

**Structure Decision**: Keep the implementation in the repository’s existing workflow-distribution layout. The reusable workflow entrypoint lives under `.github/workflows/`, consumer guidance lives under `docs/`, and validation assets are split between `tests/contract/` for the callable interface and `tests/integration/` for end-to-end strategy behavior.

## Phase 0 Research

- Decide how callers select exactly one build strategy and how invalid or ambiguous selections fail.
- Define the minimum stable output contract that downstream publish or deploy workflows can trust after a successful build.
- Compare the runner and repository prerequisites needed for Dockerfile builds versus Spring Boot buildpack builds.

## Phase 1 Design

### Data Model

- Build Strategy Selection
- Container Build Request
- Image Build Result

### Flow

1. Accept workflow inputs describing the selected build strategy and required build parameters.
2. Validate that exactly one supported strategy is selected and that required prerequisites are present.
3. Run the Dockerfile or buildpack build path based on the validated selection.
4. Capture deterministic build status and image metadata.
5. Expose outputs that tell downstream workflows whether a usable image is available.

### Validation Strategy

- Contract tests for inputs, outputs, and invalid strategy handling.
- Integration scenarios covering successful Dockerfile builds, successful buildpack builds, missing prerequisites, and ambiguous strategy selection.
- Manual dry run against a representative Spring Boot repository using both supported strategies.

## Complexity Tracking

No constitutional exceptions or additional complexity justifications are required at this stage.
