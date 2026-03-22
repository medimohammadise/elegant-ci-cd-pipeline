# Version Decision Output Expectations

## Expected Decisions

- Patch-only fixture histories produce `version_bump = patch`.
- Histories containing any minor-classified pull request and no major-classified pull request produce `version_bump = minor`.
- Histories containing any major-classified pull request produce `version_bump = major`.
- Histories with no eligible changes produce `version_bump = none`.

## Expected Failures

- Pull requests with conflicting semantic version labels fail the workflow.
- Pull requests with no recognized version labels fail the workflow when `unlabeled_behavior = fail`.
- Failure messages identify the affected pull request number.
