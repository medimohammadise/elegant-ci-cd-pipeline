# Contract: Reusable Container Build Workflow

## Purpose

Define the callable interface for a shared workflow that builds Spring Boot container images through either a Dockerfile-based path or a Spring Boot buildpack path and exposes a stable result to downstream automation.

## Responsibilities

The reusable workflow is responsible for:

- Validating that exactly one supported build strategy is selected
- Checking that the selected strategy has the minimum required repository prerequisites
- Executing the selected container build path
- Returning stable outputs that describe whether a usable image was produced

The reusable workflow is not responsible for:

- Publishing images to registries beyond the scope of the build contract unless explicitly added by callers
- Deploying built images
- Performing unrelated CI tasks such as release-note generation or environment promotion

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `build_strategy` | Yes | Strategy selector with supported values `dockerfile` or `buildpacks`. |
| `image_name` | Yes | Target image repository or name to build. |
| `image_tag` | Yes | Tag or version identifier to apply to the built image. |
| `dockerfile_path` | No | Dockerfile path used when `build_strategy=dockerfile`. |
| `build_context` | No | Build context path used for Dockerfile builds. |
| `build_tool` | No | Build tool selector for the buildpack path when repository conventions require disambiguation. |
| `java_version` | No | Runner Java version required for buildpack execution when not already implicit in the repository setup. |

## Outputs

| Output | Description |
|--------|-------------|
| `build_status` | Explicit build outcome such as `success` or `failure`. |
| `selected_strategy` | The validated strategy used for the run. |
| `image_available` | Indicates whether a usable container image was produced. |
| `image_ref` | Built image reference suitable for downstream workflows when available. |
| `image_digest` | Optional digest emitted when the build path can resolve one deterministically. |
| `failure_reason` | Actionable failure message when the build does not produce a usable image. |

## Behavioral Rules

1. The workflow must accept only one supported strategy value for each run.
2. The workflow must fail clearly when the selected strategy is unsupported or the required prerequisites are missing.
3. Dockerfile builds must execute through the Dockerfile path only.
4. Buildpack builds must execute through the Spring Boot buildpack path only.
5. Failed runs must report that no usable image is available.
6. Successful runs must expose enough image metadata for downstream workflows to continue safely.

## Consumer Expectations

Consuming repositories are expected to:

- Provide a repository revision that supports the selected strategy
- Supply image naming inputs required by their downstream publish or deploy flow
- Call the shared workflow instead of duplicating repository-local container build wrappers

## Validation Scenarios

- A valid Dockerfile-based request succeeds and returns a usable image reference.
- A valid buildpack-based request succeeds and returns a usable image reference.
- An invalid strategy value fails before any build starts.
- Missing Dockerfile prerequisites fail clearly for the Dockerfile path.
- Missing Spring Boot buildpack prerequisites fail clearly for the buildpack path.
- Failed builds do not expose a usable downstream image result.
