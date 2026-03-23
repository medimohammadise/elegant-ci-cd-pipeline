# Research: Reusable Container Image Build Workflow

## Strategy Selection Contract

- **Decision**: Represent the build path as one required workflow input with supported values `dockerfile` and `buildpacks`.
- **Rationale**: A single explicit selector enforces the requirement that each run resolves to exactly one strategy and keeps validation simple for callers.
- **Alternatives considered**:
  - Separate booleans for Dockerfile and buildpacks: rejected because dual-true and dual-false states create ambiguity.
  - Auto-detecting strategy from repository files: rejected because it can hide configuration mistakes and weaken reuse.

## Dockerfile Build Execution

- **Decision**: Use Docker Buildx as the Dockerfile-based execution path.
- **Rationale**: Buildx is the standard GitHub Actions-compatible path for deterministic Dockerfile builds and supports downstream image metadata capture cleanly.
- **Alternatives considered**:
  - Plain `docker build`: rejected because Buildx is better aligned with modern runner usage and metadata support.
  - Repository-local shell wrappers: rejected because the spec forbids non-reusable helper scripts.

## Buildpack Build Execution

- **Decision**: Use the repository’s Spring Boot build tool integration to run `bootBuildImage`.
- **Rationale**: `bootBuildImage` is the Spring Boot-native buildpack path and matches the feature requirement directly.
- **Alternatives considered**:
  - Calling `pack build` directly for every repository: rejected because it bypasses the application’s existing Spring Boot build configuration.
  - Limiting support to Gradle or Maven only: rejected because the spec requires a reusable buildpack path, not a single-tool restriction.

## Stable Downstream Outputs

- **Decision**: Expose outputs for build status, selected strategy, image reference, and image availability.
- **Rationale**: Downstream workflows need a minimal, stable contract that answers whether a usable image exists and what image identifier to continue with.
- **Alternatives considered**:
  - Returning only job success or failure: rejected because downstream workflows still need an explicit artifact signal.
  - Returning extensive runner-specific metadata only: rejected because it increases coupling without improving core decisions.

## Failure Behavior

- **Decision**: Fail the workflow before build execution when strategy selection is invalid or prerequisites for the selected path are missing.
- **Rationale**: Early validation prevents partial builds and gives maintainers a clearer reason for failure.
- **Alternatives considered**:
  - Falling back automatically to the other strategy: rejected because it violates exact strategy selection.
  - Deferring validation to underlying tools only: rejected because the resulting failures are less actionable.

## Repository Structure

- **Decision**: Implement the feature as a reusable workflow plus consumer-facing documentation and workflow-oriented validation assets.
- **Rationale**: This matches the repository’s existing layout and keeps operational logic, consumer guidance, and test scenarios separated cleanly.
- **Alternatives considered**:
  - Embedding usage guidance only inside the workflow YAML: rejected because consumer-facing behavior becomes harder to review.
  - Treating the feature as application code under `src/`: rejected because the repository distributes automation, not runtime services.
