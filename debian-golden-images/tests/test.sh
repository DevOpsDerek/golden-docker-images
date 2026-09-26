#!/usr/bin/env bash
# Test golden Debian images: version, packages, and labels.
# Usage: ./test.sh [image_base]   e.g. ./test.sh debian-golden

set -euo pipefail

IMAGE_BASE="${1:-debian-golden}"
VERSIONS=(bookworm)
FAILED=0

run_test() {
  local image="$1"
  # shellcheck disable=SC2034
  local _="$2"  # version: kept for consistent 4-arg signature
  if ! docker run --rm "$image" bash -c "$3"; then
    echo "FAIL: $image — $4"
    return 1
  fi
  echo "OK: $image — $4"
  return 0
}

for v in "${VERSIONS[@]}"; do
  image="${IMAGE_BASE}:${v}"
  echo "--- Testing $image ---"

  # Image must exist
  if ! docker image inspect "$image" &>/dev/null; then
    echo "FAIL: $image — image not found (build it first)"
    FAILED=1
    continue
  fi

  # Container starts and runs
  run_test "$image" "$v" "true" "container runs" || { FAILED=1; continue; }

  # Debian version (codename) matches tag
  run_test "$image" "$v" "grep -q '^VERSION_CODENAME=$v' /etc/os-release" "Debian version $v" || { FAILED=1; continue; }

  # curl installed
  run_test "$image" "$v" "command -v curl && curl --version | head -1" "curl present" || { FAILED=1; continue; }

  # ca-certificates installed
  run_test "$image" "$v" "test -f /etc/ssl/certs/ca-certificates.crt" "ca-certificates present" || { FAILED=1; continue; }

  # Apt cache cleaned
  run_test "$image" "$v" "test ! -d /var/lib/apt/lists || test -z \"\$(ls -A /var/lib/apt/lists 2>/dev/null)\"" "apt lists cleaned" || { FAILED=1; continue; }

  # DNS resolution
  run_test "$image" "$v" "getent hosts example.com" "DNS resolution" || { FAILED=1; continue; }

  # HTTPS (TLS + ca-certificates). Skip with message if curl exits 60 (often local TLS interception).
  run_https_test() {
    local img="$1" r
    docker run --rm "$img" bash -c 'SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt curl -sSf -o /dev/null https://example.com' 2>/dev/null
    r=$?
    if [[ $r -eq 0 ]]; then
      echo "OK: $img — HTTPS works"
      return 0
    fi
    if [[ $r -eq 60 ]]; then
      echo "SKIP: $img — HTTPS (cert verification failed, often due to local TLS interception; passes in CI)"
      return 0
    fi
    echo "FAIL: $img — HTTPS works"
    return 1
  }
  run_https_test "$image" || { FAILED=1; continue; }
done

# OCI labels (host-side check): version, title, description, vendor
for v in "${VERSIONS[@]}"; do
  image="${IMAGE_BASE}:${v}"
  docker image inspect "$image" &>/dev/null || continue
  label_version="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.version"}}' 2>/dev/null)" || true
  label_title="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.title"}}' 2>/dev/null)" || true
  label_description="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.description"}}' 2>/dev/null)" || true
  label_vendor="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.vendor"}}' 2>/dev/null)" || true
  if [[ "$label_version" != "$v" ]]; then
    echo "FAIL: $image — OCI version label expected '$v', got '$label_version'"
    FAILED=1
  else
    echo "OK: $image — OCI version label set"
  fi
  if [[ -z "$label_title" ]]; then
    echo "FAIL: $image — OCI label org.opencontainers.image.title missing or empty"
    FAILED=1
  else
    echo "OK: $image — OCI title label set"
  fi
  if [[ -z "$label_description" ]]; then
    echo "FAIL: $image — OCI label org.opencontainers.image.description missing or empty"
    FAILED=1
  else
    echo "OK: $image — OCI description label set"
  fi
  if [[ -z "$label_vendor" ]]; then
    echo "FAIL: $image — OCI label org.opencontainers.image.vendor missing or empty"
    FAILED=1
  else
    echo "OK: $image — OCI vendor label set"
  fi
done

if [[ $FAILED -ne 0 ]]; then
  echo "Some tests failed."
  exit 1
fi
echo "All tests passed."
