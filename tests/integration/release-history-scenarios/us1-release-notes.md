# User Story 1 Scenarios

## Categorized Pull Requests

- Given feature and fix pull requests merged after the current release boundary
- When the reusable workflow runs
- Then release notes contain `Features` and `Fixes` sections with the correct pull requests

## Unlabeled Pull Requests

- Given a pull request with no recognized category label
- When the reusable workflow runs
- Then the pull request appears under `Other Changes`

## Deterministic Ordering

- Given the same merged pull request history
- When the reusable workflow runs multiple times
- Then the section ordering and pull request inclusion remain stable
