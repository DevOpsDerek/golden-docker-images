#!/usr/bin/env bash
# Static checks for the manual-only Windows path; safe to run on Linux without Docker.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workflow="$root/.github/workflows/build-windows.yml"

test "$(find "$root/windows-golden-images" -name Dockerfile | wc -l | tr -d ' ')" -eq 2
for version in ltsc2022 ltsc2025; do
  dockerfile="$root/windows-golden-images/$version/Dockerfile"
  test -f "$dockerfile"
  grep -Fxq "FROM mcr.microsoft.com/windows/servercore:$version" "$dockerfile"
  test "$(grep -c '^FROM ' "$dockerfile")" -eq 1
  grep -Fq "org.opencontainers.image.version=\"$version\"" "$dockerfile"
  grep -Eq "^          - $version$" "$workflow"
done

triggers="$(sed -n '/^on:$/,/^permissions:$/p' "$workflow")"
grep -Eq '^  workflow_dispatch:$' <<< "$triggers"
if [[ "$(grep -Ec '^  [a-z_]+:' <<< "$triggers")" -ne 1 ]]; then
  echo "Windows builds must only use workflow_dispatch." >&2
  exit 1
fi
test "$(grep -Ec '^          - ' <<< "$triggers")" -eq 2
grep -Eq '^        default: false$' <<< "$triggers"
grep -Fq "inputs.version == 'ltsc2022' && 'windows-2022' || 'windows-2025'" "$workflow"
grep -Fq 'if: inputs.publish && github.ref !=' "$workflow"
grep -Fq "if: inputs.publish && github.ref == 'refs/heads/main'" "$workflow"
version_ref="\$env:VERSION"
grep -Fq "run: ./build.ps1 -Version $version_ref" "$workflow"
grep -Fq "run: ./tests/test.ps1 -Version $version_ref" "$workflow"
grep -Fq 'trivy image --image-src docker --scanners vuln --exit-code 1' "$workflow"
echo "Windows static workflow and Dockerfile controls passed."
