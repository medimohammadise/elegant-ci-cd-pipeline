# User Story 2 Scenarios

## Patch Release

- Given only patch-classified pull requests after the boundary
- Then the workflow selects `patch`

## Minor Release

- Given at least one minor-classified pull request and no major-classified pull request
- Then the workflow selects `minor`

## Major Release

- Given at least one major-classified pull request
- Then the workflow selects `major`

## Conflicting Metadata

- Given one pull request with both major and minor labels
- Then the workflow fails and identifies the pull request

## Reverted Pull Requests

- Given a pull request that is later reverted before release generation
- Then the workflow excludes the original pull request and the revert pull request from release outputs

## Empty Release

- Given no eligible merged pull requests after the release boundary
- Then the workflow returns `release_required = false`
