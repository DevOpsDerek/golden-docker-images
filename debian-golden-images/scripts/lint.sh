#!/usr/bin/env bash
# Run all linters: ShellCheck (shell), Hadolint (Dockerfiles), yamllint (YAML).
# Config files live at repo root. Requires: shellcheck, hadolint, yamllint.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$SCRIPT_DIR/.."

FAILED=0

run_linter() {
  local name="$1"
  local cmd="$2"
  shift 2
  if command -v "$cmd" &>/dev/null; then
    echo "--- $name ---"
    if "$cmd" "$@"; then
      echo "OK: $name"
    else
      echo "FAIL: $name"
      FAILED=1
    fi
  else
    echo "SKIP: $name ($cmd not installed)"
  fi
}

# Shell scripts
run_linter "ShellCheck (build.sh)" shellcheck -x build.sh
run_linter "ShellCheck (tests/test.sh)" shellcheck -x tests/test.sh
run_linter "ShellCheck (scripts/lint.sh)" shellcheck -x scripts/lint.sh

# Dockerfiles (config at repo root)
run_linter "Hadolint (Dockerfiles)" hadolint -c "$REPO_ROOT/.hadolint.yaml" bullseye/Dockerfile bookworm/Dockerfile

# YAML (repo root workflows and config)
if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  if yamllint -c "$REPO_ROOT/.yamllint.yml" \
    "$REPO_ROOT/.github/workflows/build-alpine.yml" \
    "$REPO_ROOT/.github/workflows/build-ubuntu.yml" \
    "$REPO_ROOT/.github/workflows/build-debian.yml" \
    "$REPO_ROOT/.github/workflows/build-rocky.yml" \
    "$REPO_ROOT/.github/workflows/build-windows.yml" \
    "$REPO_ROOT/.github/workflows/lint.yml" \
    "$REPO_ROOT/.yamllint.yml" \
    "$REPO_ROOT/.hadolint.yaml" \
    "$REPO_ROOT/.pre-commit-config.yaml"; then
    echo "OK: yamllint"
  else
    FAILED=1
  fi
else
  echo "SKIP: yamllint (not installed)"
fi

if [[ $FAILED -ne 0 ]]; then
  echo "Linting failed."
  exit 1
fi
echo "All linters passed."
