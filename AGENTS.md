# elegant-ci-cd-pipeline Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-31

## Active Technologies
- Repository git history, tags, workflow inputs, workflow outputs, and issue metadata
- YAML-based GitHub Actions workflow definitions with shell-driven repository metadata processing
- GitHub Actions reusable workflows, pull request metadata, repository release tags, Spec Kit planning documents, and issue-driven feature automation
- YAML-based GitHub Actions workflows with shell-driven repository metadata processing + GitHub Actions `issues` event payloads, `actions/github-script`, reusable workflow call to `.github/workflows/codex-spec-kit-agent.yml`, repository-local Codex prompt files (008-issue-spec-automation)
- GitHub issue metadata, workflow outputs, issue comments, generated `specs/` artifacts produced by the downstream workflow (008-issue-spec-automation)
- YAML-based GitHub Actions workflows with inline JavaScript via `actions/github-script@v7` and shell validation scripts + GitHub Actions reusable workflows, `actions/github-script@v7`, Codex CLI runner integration, Spec Kit bash helpers (008-issue-spec-automation)
- GitHub issues/comments, workflow inputs/outputs, repository files under `specs/` and `tests/` (008-issue-spec-automation)

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
- 008-issue-spec-automation: Added YAML-based GitHub Actions workflows with inline JavaScript via `actions/github-script@v7` and shell validation scripts + GitHub Actions reusable workflows, `actions/github-script@v7`, Codex CLI runner integration, Spec Kit bash helpers
- 008-issue-spec-automation: Added YAML-based GitHub Actions workflows with inline JavaScript via `actions/github-script@v7` and shell validation scripts + GitHub Actions reusable workflows, `actions/github-script@v7`, Codex CLI runner integration, Spec Kit bash helpers
- 008-issue-spec-automation: Added YAML-based GitHub Actions workflows with shell-driven repository metadata processing + GitHub Actions `issues` event payloads, `actions/github-script`, reusable workflow call to `.github/workflows/codex-spec-kit-agent.yml`, repository-local Codex prompt files

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
