#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

require_file() {
  local file="$1"

  if [[ ! -f "$ROOT_DIR/$file" ]]; then
    echo "FAIL: missing required file $file"
    FAILED=1
    return 0
  fi

  echo "OK: found $file"
}

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"

  if ! grep -Fq "$text" "$ROOT_DIR/$file"; then
    echo "FAIL: $file is missing $description"
    FAILED=1
    return 0
  fi

  echo "OK: $file includes $description"
}

require_file "README.md"
require_file "docs/supply-chain-golden-path.md"
require_file "docs/adr/0001-immutable-image-identities.md"

require_text "README.md" "## Supply-chain hardening" "the root supply-chain overview section"
require_text "docs/supply-chain-golden-path.md" "## Ownership and cadence assumptions" "ownership and cadence guidance"
require_text "docs/supply-chain-golden-path.md" "## Promotion and deployment identity" "promotion identity guidance"
require_text "docs/supply-chain-golden-path.md" "## SBOM, provenance, signing, and verification" "SBOM/signing guidance"
require_text "docs/supply-chain-golden-path.md" "## Response to vulnerable base images" "vulnerable base response guidance"
require_text "docs/adr/0001-immutable-image-identities.md" "Immutable digests are the promotion and deployment identity." "the immutable digest ADR decision"

for workflow in \
  ".github/workflows/build-alpine.yml" \
  ".github/workflows/build-ubuntu.yml" \
  ".github/workflows/build-debian.yml" \
  ".github/workflows/build-rocky.yml"; do
  require_text "$workflow" "Run Trivy vulnerability scanner" "the Trivy scan step"
  require_text "$workflow" "Generate SBOMs" "the SBOM generation step"
  require_text "$workflow" "Upload SBOM artifacts" "the SBOM upload step"
  require_text "$workflow" "anchore/syft:latest" "the Syft container invocation"
done

if [[ $FAILED -ne 0 ]]; then
  echo "Supply-chain validation failed."
  exit 1
fi

echo "Supply-chain validation passed."
