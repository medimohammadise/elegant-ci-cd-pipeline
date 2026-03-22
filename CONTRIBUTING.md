# Contributing

## Scope

This repository uses `CONTRIBUTING.md` as the source of truth for contributor workflow conventions, including Git commit structure. Human contributors and AI agents should follow the same rules.

## Architecture Principles

Contributors should preserve this repository as a reusable GitHub Actions workflow project. In practice, that means:

- Keep reusable workflow entrypoints under `.github/workflows/`.
- Design workflows to be reusable across repositories, with documented inputs, outputs, permissions, and behavior contracts.
- Prefer repository-local helper logic under `.specify/` or documented workflow steps instead of scattering ad hoc automation across unrelated directories.
- Treat `specs/` as the planning and traceability record for workflow features, with one feature directory per planned capability.
- Keep `tests/contract/` focused on workflow interfaces and documented behavior expectations.
- Keep `tests/integration/` focused on end-to-end repository scenarios that validate workflow behavior across realistic history and metadata conditions.
- Maintain `docs/` for operator-facing guidance, workflow usage notes, release behavior, and other repository-level documentation.
- Preserve clear separation between reusable automation behavior, planning artifacts, and validation assets.
- Update contributor and operator documentation whenever workflow triggers, permissions, inputs, outputs, generated artifacts, or repository conventions change.

Repository layout reference:

- `.github/workflows/` contains reusable workflow definitions.
- `.specify/` contains Spec Kit templates and automation scripts used to create and plan features.
- `specs/` contains feature specifications, implementation plans, checklists, and task lists.
- `tests/contract/` contains workflow contracts and documented interface expectations.
- `tests/integration/` contains end-to-end workflow behavior scenarios.
- `docs/` contains operator-facing documentation and workflow usage guidance.

The expected repository shape is:

```text
.github/workflows/   reusable workflow definitions
.specify/            Spec Kit templates and scripts
docs/                operator and workflow documentation
specs/               feature specifications, plans, and tasks
tests/contract/      workflow contracts and interface expectations
tests/integration/   end-to-end workflow scenarios
```

When a change would violate one of these principles, either redesign it to fit the existing architecture or update the architecture docs and related roots together as one deliberate change.

## Commit Messages

Use semantic commit messages in the form:

```text
<type>: <summary>
```

Examples:

- `feat: add issue-triggered planning workflow`
- `fix: correct release note output mapping`
- `docs: update workflow usage guide`
- `refactor: simplify workflow input handling`
- `chore: refresh test fixtures`

Prefer these commit types:

- `feat` for new user-visible capabilities
- `fix` for bug fixes or regressions
- `docs` for documentation-only changes
- `refactor` for structural changes without intended behavior change
- `chore` for maintenance, tooling, or non-feature housekeeping

Commit summaries should be short, imperative, and specific to the change.

## Squash Preference

Prefer a small, reviewable history. If a branch contains iterative fixup commits for one logical change, squash them before merging or pushing final review updates.

## Labels

If pull requests or issues use labels, keep them aligned with the commit intent and scope. Typical labels should reflect:

- change type, such as `feature`, `bug`, `docs`, or `chore`
- affected area, such as `workflows`, `release-notes`, `spec-kit`, `tests`, or `docs`

Do not invent new labels casually. Reuse the repository's existing label taxonomy when available.

## Versioning

When changes affect release notes, changelog generation, or version semantics, keep commit messages and PR descriptions clear enough to support downstream automation.

## Agent Guidance

AI agents working in this repository should:

- read this file before preparing commits
- prefer one semantic commit per logical change unless the user asks otherwise
- keep generated commit messages consistent with the conventions above
