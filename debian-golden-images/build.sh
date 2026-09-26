#!/usr/bin/env bash
# Build all golden Debian images.
# Usage: ./build.sh [registry[/repo]]   e.g. ./build.sh ghcr.io/myorg/debian-golden

set -euo pipefail

REGISTRY="${1:-debian-golden}"
VERSIONS=(bookworm)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for v in "${VERSIONS[@]}"; do
  echo "Building $REGISTRY:$v ..."
  docker build -t "$REGISTRY:$v" -f "$SCRIPT_DIR/$v/Dockerfile" "$SCRIPT_DIR/$v"
done

echo "Done. Images:"
docker images "$REGISTRY" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
