# Release Policy

## Semantic Version Rules

The reusable workflow selects a single semantic version bump from all eligible merged pull requests after the release boundary.

Precedence:

1. `major`
2. `minor`
3. `patch`

Any `major` pull request forces a major release. If there is no major pull request, any `minor` pull request forces a minor release. Otherwise the release defaults to patch.

## Suggested Version Labels

- `release:major`
- `release:minor`
- `release:patch`

## Suggested Category Labels

- `type:feature`
- `type:fix`
- `type:docs`
- `type:maintenance`

## Fallback Rules

- Unrecognized category labels route the pull request to `Other Changes`.
- Unrecognized version labels default to `patch` unless the workflow is called with `unlabeled_behavior: fail`.
- Conflicting semantic version labels fail the workflow.

## Revert Policy

When `revert_handling` is set to `exclude_reverted`, the workflow excludes:

- revert pull requests that clearly reference an earlier pull request
- the earlier pull request referenced by that revert

This keeps release notes aligned with net shipped behavior instead of transient merge history.

## Release Boundary

The workflow resolves the release boundary in this order:

1. Explicit `release_boundary` input
2. Most recent tag reachable from the configured base branch
3. No boundary, which causes the workflow to treat all merged pull requests on the base branch as eligible

## Failure Messaging

Failure messages should clearly identify:

- the pull request number involved
- whether the issue is missing metadata or conflicting metadata
- which inputs or labels the caller should correct
