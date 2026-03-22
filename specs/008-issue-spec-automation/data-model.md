# Data Model: Issue-Driven Spec Planning Workflow

## Issue Intake Record

- **Purpose**: Represents the newly created issue that starts planning.
- **Attributes**:
  - Issue number
  - Issue title
  - Issue body
  - Issue URL
  - Creation timestamp
  - Current processing eligibility

## Feature Artifact Set

- **Purpose**: Represents the full set of planning outputs created from one issue.
- **Attributes**:
  - Feature number
  - Branch name
  - Spec directory path
  - Spec file path
  - Plan file path
  - Tasks file path
  - Checklist path
  - Originating issue number

## Run Outcome

- **Purpose**: Captures the result of one automation attempt.
- **Attributes**:
  - Issue number
  - Outcome status (`created`, `skipped`, `failed`)
  - Outcome message
  - Duplicate detection result
  - Created artifact references
  - Completion timestamp

## Relationships

- One Issue Intake Record can produce at most one primary Feature Artifact Set.
- One Issue Intake Record can have multiple Run Outcome records across retries, but only one successful artifact-creation outcome.
- Each Run Outcome references exactly one Issue Intake Record and may reference one Feature Artifact Set.
