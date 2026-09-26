#!/usr/bin/env bash

set -euo pipefail

DOC="docs/supply-chain-golden-path.md"

if [[ ! -f "$DOC" ]]; then
  echo "ERROR: required policy doc missing: $DOC"
  exit 1
fi

required_sections=(
  "## Ownership and decision authority"
  "## Supported base images"
  "## Update cadence and rebuild policy"
  "## Image lifecycle"
  "## Promotion identity and deployment guidance"
  "## Signature and verification expectations"
  "## Vulnerable base image response playbook"
  "## Exception process"
)

for section in "${required_sections[@]}"; do
  if ! grep -Fxq -- "$section" "$DOC"; then
    echo "ERROR: missing required section in $DOC: $section"
    exit 1
  fi
done

if ! grep -Fq "maintainer confirmation required" "$DOC"; then
  echo "ERROR: expected at least one 'maintainer confirmation required' marker in $DOC"
  exit 1
fi

if ! grep -Fq "@sha256:" "$DOC"; then
  echo "ERROR: expected immutable digest guidance example (@sha256:) in $DOC"
  exit 1
fi

echo "Supply-chain documentation validation passed."
