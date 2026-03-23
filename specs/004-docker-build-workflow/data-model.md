# Data Model: Reusable Container Image Build Workflow

## Build Strategy Selection

- **Purpose**: Represents the single approved containerization approach for one workflow run.
- **Attributes**:
  - Strategy name (`dockerfile` or `buildpacks`)
  - Validation status
  - Prerequisite summary

## Container Build Request

- **Purpose**: Represents one invocation of the reusable container build workflow.
- **Attributes**:
  - Source repository reference
  - Source revision
  - Selected build strategy
  - Requested image name
  - Requested image tag or version input
  - Optional build context or builder settings

## Image Build Result

- **Purpose**: Represents the outcome exposed to downstream automation after the build attempt.
- **Attributes**:
  - Result status (`success` or `failure`)
  - Selected strategy
  - Image availability flag
  - Built image reference
  - Optional image digest
  - Failure message when no usable image is available

## Relationships

- One Container Build Request must reference exactly one Build Strategy Selection.
- One Container Build Request produces exactly one Image Build Result.
- One successful Image Build Result may expose a built image reference and optional digest for downstream use.
- One failed Image Build Result must report that no deployable image is available.
