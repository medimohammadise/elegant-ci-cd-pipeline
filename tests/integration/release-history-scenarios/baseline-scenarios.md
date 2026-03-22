# Baseline Release History Scenarios

## Baseline Cases

- A repository with a latest release tag and one merged pull request after that tag
- A repository with multiple merged pull requests across multiple categories
- A repository with no prior release tag
- A repository with no merged pull requests after the current release boundary

## Expected Outcomes

- The workflow resolves a release boundary deterministically.
- Eligible pull requests are included only once.
- The workflow emits stable markdown and JSON outputs.
