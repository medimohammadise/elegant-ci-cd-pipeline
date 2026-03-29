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
- Document reusable workflow interfaces with explicit tables. Workflow docs should include input tables with `Input`, `Description`, `Required`, and `Default`, and output tables with `Output`, `Description`, and `Required`. If a workflow has no declared `workflow_call` outputs, say so explicitly.

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

## Scripting Language Guidelines

Inline workflow logic can be written in several ways. Choose based on what the step needs to do:

### Bash (`run:` steps)
Use for simple shell operations: file manipulation, environment variable wiring, invoking CLI tools, or glue between steps.

```yaml
- run: echo "TAG=$(git describe --tags --abbrev=0)" >> "$GITHUB_ENV"
```

Avoid Bash for anything requiring HTTP calls, JSON parsing beyond `jq` one-liners, or multi-branch logic — it becomes hard to read and test quickly.

### JavaScript via `actions/github-script` (`uses: actions/github-script`)
Use when the step needs the GitHub API (`github.rest.*`), access to workflow context (`context`), or logic complex enough to benefit from a real language (loops, maps, error handling).

```yaml
- uses: actions/github-script@v8
  with:
    script: |
      const { data } = await github.rest.pulls.list({ owner, repo, state: "closed" });
```

This is plain Node.js — no TypeScript, no imports from `node_modules` beyond what the runner provides (`node:child_process`, etc.).

**Structure guidelines for non-trivial scripts:**
- Extract each logical phase into a named function (git ops, API calls, classification, output emission).
- Keep the top-level execution block short — it should read as a pipeline of function calls.
- Pass dependencies explicitly into functions; avoid relying on closure over globals.

### Pre-compiled JavaScript action (`using: node20`)
Use when the script is large enough that inline YAML becomes hard to review, needs `npm` dependencies, or should be versioned and reused across multiple workflows. TypeScript is supported but must be compiled to `dist/index.js` before the action runs.

Place the action under `.github/actions/<name>/` and reference it as `uses: ./.github/actions/<name>`.

### Docker action (`using: docker`)
Use when the logic is better expressed in another language (Python, Go, etc.), requires a specific runtime or system dependency, or is complex enough to warrant a proper project structure with tests.

Place the action under `.github/actions/<name>/` with a `Dockerfile` and reference it as `uses: ./.github/actions/<name>`.

### Decision summary

| Need | Preferred approach |
|---|---|
| Shell glue, CLI invocation | Bash `run:` step |
| GitHub API calls + moderate logic | `actions/github-script` (inline JS) |
| Large script, needs npm packages | Pre-compiled JS action |
| Non-JS language or complex runtime | Docker action |

## Workflow Documentation

When editing or adding reusable workflows:

- keep README or operator-facing workflow docs aligned with the current YAML definitions
- document workflow inputs in a table with `Input`, `Description`, `Required`, and `Default`
- document workflow outputs in a table with `Output`, `Description`, and `Required`
- explicitly note when a workflow exposes no declared `workflow_call` outputs
- avoid presenting local-only or untracked workflow files as if they are committed branch state

## Agent Guidance

AI agents working in this repository should:

- read this file before preparing commits
- prefer one semantic commit per logical change unless the user asks otherwise
- keep generated commit messages consistent with the conventions above
