# User Story 3 Scenarios

## Shared Consumer Contract

- Given two repositories call the reusable workflow with the same metadata policy
- When each repository runs the workflow
- Then both repositories receive the same output fields and decision behavior

## Consumer Overrides

- Given a repository overrides category and version rules through inputs
- When the workflow runs
- Then the workflow honors those overrides without changing the callable interface

## No Local Helper Scripts

- Given a consuming repository invokes the workflow directly through `uses:`
- When the workflow runs
- Then no repository-local helper script is required to generate release notes or version decisions
