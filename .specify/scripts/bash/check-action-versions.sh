#!/usr/bin/env bash
# check-action-versions.sh
#
# Validate that every external GitHub Actions `uses:` reference in workflow
# files matches the approved version recorded in the version manifest.
#
# Usage:
#   check-action-versions.sh [--manifest <path>] [--workflows-dir <path>] [--strict]
#
# Options:
#   --manifest <path>       Path to the version manifest YAML.
#                           Default: .github/actions-versions.yml
#   --workflows-dir <path>  Directory containing workflow YAML files to scan.
#                           Default: .github/workflows
#   --strict                Also fail when a workflow references an action that
#                           has no entry in the manifest. Without this flag,
#                           unregistered actions produce a warning only.
#
# Exit codes:
#   0  All checked references align with the manifest.
#   1  One or more mismatches or (with --strict) unregistered actions found.
#   2  Manifest file not found or unreadable.
#
# Requires: bash 3.2+, grep, awk, sed (all pre-installed on ubuntu-latest and macOS)

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
MANIFEST=".github/actions-versions.yml"
WORKFLOWS_DIR=".github/workflows"
STRICT=0

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest)
      MANIFEST="$2"
      shift 2
      ;;
    --workflows-dir)
      WORKFLOWS_DIR="$2"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# ── Validate manifest exists ──────────────────────────────────────────────────
if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: Manifest file not found: $MANIFEST" >&2
  echo "       Create the file or specify a path with --manifest <path>" >&2
  exit 2
fi

# ── Parse manifest into a temp lookup file ────────────────────────────────────
# Manifest YAML structure:
#   actions:
#     owner/repo:
#       version: vN
#
# Output format per line in the temp file: "owner/repo TAB vN"

LOOKUP_FILE=$(mktemp)
trap 'rm -f "$LOOKUP_FILE"' EXIT

awk '
  /^actions:/ { in_block=1; current=""; next }
  in_block && /^[a-zA-Z]/ { in_block=0; current=""; next }
  !in_block { next }
  /^[[:space:]]*#/ { next }
  /^[[:space:]]{2}[^ ]/ && !/version:/ && !/description:/ {
    # Two-space-indented line that is an action key
    gsub(/^[[:space:]]+/, ""); gsub(/:.*$/, ""); current=$0; next
  }
  /^[[:space:]]{4}version:/ && current != "" {
    gsub(/^[[:space:]]+version:[[:space:]]+/, "")
    gsub(/#.*$/, "")
    gsub(/[[:space:]]+$/, "")
    print current "\t" $0
    next
  }
' "$MANIFEST" > "$LOOKUP_FILE"

if [[ ! -s "$LOOKUP_FILE" ]]; then
  echo "ERROR: No action entries found in manifest: $MANIFEST" >&2
  echo "       Verify the file has an 'actions:' block with version entries." >&2
  exit 2
fi

# ── Scan workflow files ───────────────────────────────────────────────────────
mismatches=()
unregistered=()

for workflow_file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
  [[ -f "$workflow_file" ]] || continue

  line_num=0
  while IFS= read -r line; do
    line_num=$(( line_num + 1 ))

    # Match lines containing `uses: <value>` (handles indented steps)
    if echo "$line" | grep -q "uses:"; then
      # Extract the value after `uses:`
      ref=$(echo "$line" | sed 's/.*uses:[[:space:]]*//' | sed 's/[[:space:]]*$//')

      # Skip empty, local workflow refs, and lines without @
      [[ -z "$ref" ]] && continue
      [[ "$ref" == ./* ]] && continue
      echo "$ref" | grep -q "@" || continue

      # Split on '@' to get action key and version
      action_key=$(echo "$ref" | cut -d@ -f1)
      found_version=$(echo "$ref" | cut -d@ -f2)

      # Look up in manifest
      expected_version=$(awk -F'\t' -v key="$action_key" '$1 == key { print $2 }' "$LOOKUP_FILE")

      if [[ -n "$expected_version" ]]; then
        if [[ "$found_version" != "$expected_version" ]]; then
          mismatches+=("$workflow_file:$line_num $action_key — found: $found_version, expected: $expected_version")
        fi
      else
        unregistered+=("$workflow_file:$line_num $action_key@$found_version — not in $MANIFEST")
      fi
    fi
  done < "$workflow_file"
done

# ── Report results ────────────────────────────────────────────────────────────
exit_code=0

if [[ ${#mismatches[@]} -gt 0 ]]; then
  exit_code=1
  echo "DRIFT DETECTED: ${#mismatches[@]} mismatch(es) found"
  echo ""
  for entry in "${mismatches[@]}"; do
    echo "  [MISMATCH] $entry"
  done
  echo ""
fi

if [[ ${#unregistered[@]} -gt 0 ]]; then
  if [[ $STRICT -eq 1 ]]; then
    exit_code=1
    echo "UNREGISTERED ACTIONS: ${#unregistered[@]} action(s) not in manifest"
  else
    echo "WARNING: ${#unregistered[@]} action(s) not registered in manifest"
  fi
  echo ""
  for entry in "${unregistered[@]}"; do
    echo "  [UNREGISTERED] $entry"
  done
  echo ""
fi

if [[ $exit_code -ne 0 ]]; then
  echo "ACTION REQUIRED: Update workflow files or register actions in $MANIFEST"
  echo "Exit code: $exit_code"
  exit $exit_code
fi

echo "✓ All action versions aligned with manifest."
exit 0
