# Quickstart: Reusable Container Image Build Workflow

## Goal

Validate that a Spring Boot repository can call one reusable workflow to build a container image through either Dockerfile or buildpacks and receive a stable downstream result.

## Manual Validation Steps

1. Prepare a Spring Boot repository that contains either a valid `Dockerfile` or a valid Spring Boot build configuration for `bootBuildImage`.
2. Call the reusable workflow with `build_strategy=dockerfile` and provide the required image naming inputs.
3. Verify the workflow completes successfully and returns a usable image result for the Dockerfile path.
4. Call the same reusable workflow with `build_strategy=buildpacks` against a repository revision that supports `bootBuildImage`.
5. Verify the workflow completes successfully and returns a usable image result for the buildpack path.
6. Invoke the workflow with an invalid or missing strategy value and confirm that it fails before build execution with a clear message.
7. Invoke the workflow with missing prerequisites for the selected strategy and confirm that it fails without exposing a usable image output.

## Expected Result

- The same reusable workflow interface supports both approved containerization strategies.
- Every run returns an explicit success or failure outcome.
- Downstream workflows can distinguish a usable image result from a failed build without reading logs manually.
