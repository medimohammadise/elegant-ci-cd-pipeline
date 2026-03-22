# elegant-ci-cd-pipeline Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-22

## Active Technologies
- Repository git history, tags, workflow inputs, workflow outputs, and issue metadata
- YAML-based GitHub Actions workflow definitions with shell-driven repository metadata processing
- GitHub Actions reusable workflows, pull request metadata, repository release tags, Spec Kit planning documents, and issue-driven feature automation

## Project Structure

```text
.github/workflows/
.specify/
docs/
specs/
tests/contract/
tests/integration/
```

## Commands

- Use `.specify/scripts/bash/create-new-feature.sh` to create numbered Spec Kit feature branches and directories.
- Use `.specify/scripts/bash/setup-plan.sh --json` to initialize a feature plan on a Spec Kit branch.
- Validate workflow behavior through the contract and integration assets under `tests/`.

## Code Style

- Follow standard YAML and shell conventions for GitHub Actions workflow definitions.
- Keep reusable workflow interfaces explicit: declare permissions, inputs, outputs, and failure behavior clearly.
- Keep repository documentation aligned with workflow behavior and generated planning artifacts.

## Recent Changes
- 008-issue-spec-automation: Added issue-driven Spec Kit planning artifacts for automating spec, plan, and task generation from new issues
- 007-spec-issue-capture: Added reusable specification-to-issue capture requirements
- 001-release-notes-workflow: Added reusable release-notes workflow planning and documentation

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
