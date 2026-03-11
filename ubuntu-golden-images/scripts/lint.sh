#!/usr/bin/env bash
# Run all linters: ShellCheck (shell), Hadolint (Dockerfiles), yamllint (YAML).
# Requires: shellcheck, hadolint, yamllint (see README for install).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

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

# Dockerfiles
run_linter "Hadolint (Dockerfiles)" hadolint 18.04/Dockerfile 20.04/Dockerfile 22.04/Dockerfile 24.04/Dockerfile

# YAML (GitHub workflows and config)
if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  if yamllint -c .yamllint.yml .github/workflows/build.yml .github/workflows/lint.yml .yamllint.yml .hadolint.yaml .pre-commit-config.yaml; then
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
