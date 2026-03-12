#!/usr/bin/env bash
# Run linters for Windows golden images: Hadolint (Dockerfiles), yamllint (workflow).
# Config files live at repo root. Requires: hadolint, yamllint. No shell scripts to ShellCheck.

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

# Dockerfiles (config at repo root; hadolint supports Windows Dockerfiles)
run_linter "Hadolint (Dockerfiles)" hadolint -c "$REPO_ROOT/.hadolint.yaml" ltsc2019/Dockerfile ltsc2022/Dockerfile ltsc2025/Dockerfile

# YAML (repo root workflow)
if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  if yamllint -c "$REPO_ROOT/.yamllint.yml" \
    "$REPO_ROOT/.github/workflows/build-windows.yml"; then
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
