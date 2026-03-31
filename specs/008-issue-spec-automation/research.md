# Research: Issue-Driven Spec Planning Workflow

## Decision 1: Trigger on issue creation

- **Decision**: Start the intake workflow from the repository `issues` `opened` event.
- **Rationale**: The requested behavior is immediate planning after issue intake, and the `opened` event is the earliest stable signal for a new feature request.
- **Alternatives considered**:
  - Manual dispatch only: rejected because it preserves the manual intake step this feature is intended to remove.
  - Comment-based trigger: rejected because it adds a second required user action after issue creation.

## Decision 2: Call the reusable Codex Spec Kit workflow directly

- **Decision**: The issue-opened workflow should call `.github/workflows/codex-spec-kit-agent.yml` rather than creating branches or generating planning artifacts itself.
- **Rationale**: The clarified specification explicitly requires the issue-created workflow to avoid direct branch creation and to delegate planning to the existing Codex Spec Kit workflow.
- **Alternatives considered**:
  - Inline branch creation and artifact generation in `issue-spec-automation.yml`: rejected because it conflicts with the clarified spec and duplicates downstream planning behavior.
  - `repository_dispatch` to an indirect pipeline: rejected because the clarified behavior is a direct call to `codex-spec-kit-agent.yml`, which already exposes reusable workflow inputs.

## Decision 3: Use `$speckit.specify <issue body>` as the downstream command input

- **Decision**: Build the downstream command input as `$speckit.specify <issue body>`, using the normalized issue body as the natural-language feature description.
- **Rationale**: The reusable Codex workflow accepts a single command-style input, and the clarified behavior explicitly says the handoff should use `$speckit.specify <issue body>`.
- **Alternatives considered**:
  - Pass issue metadata as a structured JSON payload: rejected because the clarified requirement is prompt-body driven, and `speckit.specify` already expects natural-language feature input.
  - Use `$speckit.plan` or `$speckit.tasks` directly: rejected because specification must be generated first.

## Decision 4: Detect duplicates by originating issue outcome marker

- **Decision**: Treat the originating issue as the idempotency key and record a durable issue comment marker after a successful handoff start so repeated runs can skip safely.
- **Rationale**: Since the intake workflow no longer creates branches itself, duplicate prevention must attach to the issue identity and visible workflow outcome rather than local branch existence alone.
- **Alternatives considered**:
  - Detect duplicates only by downstream branch name: rejected because branch creation happens later in the downstream workflow.
  - Detect duplicates only by issue title: rejected because different issues can share similar titles.

## Decision 5: Report visible outcome in the issue thread

- **Decision**: Publish a maintainer-facing issue comment containing the run status, message, prompt reference, and downstream handoff details.
- **Rationale**: Maintainers reviewing the issue should be able to understand whether the workflow skipped, failed, or started the downstream planning handoff without opening Actions logs.
- **Alternatives considered**:
  - Workflow-only reporting: rejected because it hides state from issue-centric review.
  - Silent skip behavior: rejected because it makes duplicate and validation outcomes ambiguous.
