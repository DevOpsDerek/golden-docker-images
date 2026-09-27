#!/usr/bin/env bash
# Run static linters for Windows Server Core image family.

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

run_linter "ShellCheck (tests/test.sh)" shellcheck -x tests/test.sh
run_linter "ShellCheck (scripts/lint.sh)" shellcheck -x scripts/lint.sh
run_linter "Hadolint (Dockerfiles)" hadolint -c "$REPO_ROOT/.hadolint.yaml" ltsc2022/Dockerfile ltsc2025/Dockerfile

if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  if yamllint -c "$REPO_ROOT/.yamllint.yml" \
    "$REPO_ROOT/.github/workflows/build-windows-server-core.yml" \
    "$REPO_ROOT/.yamllint.yml"; then
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
