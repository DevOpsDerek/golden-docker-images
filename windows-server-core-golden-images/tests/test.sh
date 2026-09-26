#!/usr/bin/env bash
# Focused Windows Server Core tests.
# Usage:
#   ./tests/test.sh [image_base] [target_version]
# Static checks always run. Runtime checks run only when target_version is provided.

set -euo pipefail

IMAGE_BASE="${1:-windows-server-core-golden}"
TARGET_VERSION="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FAILED=0

expected_versions=(ltsc2022 ltsc2025)

if [[ -n "$TARGET_VERSION" && "$TARGET_VERSION" != "ltsc2022" && "$TARGET_VERSION" != "ltsc2025" ]]; then
  echo "FAIL: target_version must be ltsc2022 or ltsc2025"
  exit 1
fi

mapfile -t actual_versions < <(
  for d in "$ROOT_DIR"/ltsc*/; do
    [[ -d "$d" ]] || continue
    basename "$d"
  done | sort
)
if [[ "${actual_versions[*]}" != "${expected_versions[*]}" ]]; then
  echo "FAIL: expected LTSC directories '${expected_versions[*]}', got '${actual_versions[*]}'"
  FAILED=1
else
  echo "OK: only supported LTSC directories are present (${expected_versions[*]})"
fi

for v in "${expected_versions[@]}"; do
  dockerfile="$ROOT_DIR/$v/Dockerfile"
  if [[ ! -f "$dockerfile" ]]; then
    echo "FAIL: missing $dockerfile"
    FAILED=1
    continue
  fi

  if ! grep -Fq "ARG BASE_IMAGE=mcr.microsoft.com/windows/servercore:$v" "$dockerfile"; then
    echo "FAIL: $dockerfile must set ARG BASE_IMAGE to mcr.microsoft.com/windows/servercore:$v"
    FAILED=1
  else
    echo "OK: $dockerfile sets ARG BASE_IMAGE to servercore:$v"
  fi

  if ! grep -Fq "FROM \${BASE_IMAGE}" "$dockerfile"; then
    echo "FAIL: $dockerfile must build FROM \${BASE_IMAGE}"
    FAILED=1
  else
    echo "OK: $dockerfile builds FROM \${BASE_IMAGE}"
  fi

  if ! grep -Fq "org.opencontainers.image.version=\"$v\"" "$dockerfile"; then
    echo "FAIL: $dockerfile must set OCI version label to $v"
    FAILED=1
  else
    echo "OK: $dockerfile sets OCI version label to $v"
  fi
done

if [[ -n "$TARGET_VERSION" ]]; then
  image="$IMAGE_BASE:$TARGET_VERSION"
  echo "--- Runtime checks for $image ---"

  if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo "FAIL: $image not found (build it first)"
    FAILED=1
  else
    runtime_output=""
    runtime_output_normalized=""
    if runtime_output="$(docker run --rm "$image" powershell.exe -NoLogo -NoProfile -Command "Write-Output 'container-runs'" 2>&1)"; then
      runtime_output_normalized="${runtime_output//$'\r'/}"
    fi

    if [[ -n "$runtime_output_normalized" ]] && grep -q '^container-runs$' <<<"$runtime_output_normalized"; then
      echo "OK: $image container starts"
    else
      echo "FAIL: $image container failed runtime command"
      if [[ -n "$runtime_output" ]]; then
        echo "$runtime_output"
      fi
      FAILED=1
    fi

    version_label="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.version"}}' 2>/dev/null || true)"
    if [[ "$version_label" == "$TARGET_VERSION" ]]; then
      echo "OK: $image OCI version label matches $TARGET_VERSION"
    else
      echo "FAIL: $image OCI version label expected $TARGET_VERSION, got '$version_label'"
      FAILED=1
    fi
  fi
else
  echo "SKIP: runtime container checks (set target_version to ltsc2022 or ltsc2025 to enable)"
fi

if [[ $FAILED -ne 0 ]]; then
  echo "Some tests failed."
  exit 1
fi

echo "All tests passed."
