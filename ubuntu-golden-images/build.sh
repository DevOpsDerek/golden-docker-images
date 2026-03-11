#!/usr/bin/env bash
# Build all golden Ubuntu LTS images.
# Usage: ./build.sh [registry[/repo]]   e.g. ./build.sh ghcr.io/myorg/ubuntu-golden

set -euo pipefail

REGISTRY="${1:-ubuntu-golden}"
VERSIONS=(18.04 20.04 22.04 24.04)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for v in "${VERSIONS[@]}"; do
  echo "Building $REGISTRY:$v ..."
  docker build -t "$REGISTRY:$v" -f "$SCRIPT_DIR/$v/Dockerfile" "$SCRIPT_DIR/$v"
done

echo "Done. Images:"
docker images "$REGISTRY" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
