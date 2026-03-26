# Engineering Constitution

## 1. GitHub Actions Naming Convention

### Workflow File Naming
- Use kebab-case
- Use prefixes: ci-, cd-, cleanup-, reusable-

Examples:
- ci-build.yml
- cd-deploy.yml
- cleanup-workflow-runs.yml
- reusable-cleanup-workflow-runs.yml

### Workflow Display Name
```yaml
name: Cleanup old and failed workflow runs
```

### Job Naming
```yaml
jobs:
  cleanup-runs:
```

### Step Naming
```yaml
- name: Delete old workflow runs
```

---

## 2. Secrets Naming Convention

- Use UPPER_SNAKE_CASE
- Be explicit and descriptive

Examples:
- GHCR_TOKEN
- AWS_ACCESS_KEY_ID
- DB_PASSWORD

Usage:
```yaml
${{ secrets.GHCR_TOKEN }}
```

---

## 3. Environment Naming Convention

- Use lowercase
- Standard names only

Allowed:
- dev
- test
- staging
- prod

Example:
```yaml
environment: prod
```

---

## 4. Docker Rules

- Do NOT use wildcards in COPY
- Use deterministic naming

Gradle:
```kotlin
tasks.named<BootJar>("bootJar") {
    archiveFileName.set("app.jar")
}
```

Dockerfile:
```dockerfile
COPY build/libs/app.jar app.jar
```

---

## 5. Versioning Strategy

- Use version in:
  - Git tags (v1.0.0)
  - Docker image tags
- Do NOT rely on filename versioning

---

## 6. CI/CD Principles

- Keep workflows small and reusable
- Use reusable workflows via workflow_call
- Use least privilege permissions

Example:
```yaml
permissions:
  contents: read
  actions: write
```

---

## 7. General Rules

- Prefer clarity over brevity
- Avoid duplication
- Keep naming consistent across repo
