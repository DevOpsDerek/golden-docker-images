#!/usr/bin/env bash
# Test golden Alpine images: version, packages, and labels.
# Usage: ./test.sh [image_base]   e.g. ./test.sh alpine-golden

set -euo pipefail

IMAGE_BASE="${1:-alpine-golden}"
VERSIONS=(3.17 3.18 3.19 3.20)
FAILED=0

run_test() {
  local image="$1"
  local _="$2"  # version: kept for consistent 4-arg signature
  if ! docker run --rm "$image" sh -c "$3"; then
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

  # Alpine version matches tag (VERSION_ID is e.g. 3.18.0)
  run_test "$image" "$v" "grep -q \"VERSION_ID=.*${v}\" /etc/os-release" "Alpine version $v" || { FAILED=1; continue; }

  # curl installed
  run_test "$image" "$v" "command -v curl && curl --version | head -1" "curl present" || { FAILED=1; continue; }

  # ca-certificates installed
  run_test "$image" "$v" "test -f /etc/ssl/certs/ca-certificates.crt" "ca-certificates present" || { FAILED=1; continue; }

  # apk cache clean (--no-cache leaves cache empty or minimal)
  run_test "$image" "$v" "test ! -d /var/cache/apk || test -z \"\$(ls -A /var/cache/apk 2>/dev/null)\"" "apk cache cleaned" || { FAILED=1; continue; }

  # DNS resolution
  run_test "$image" "$v" "nslookup example.com" "DNS resolution" || { FAILED=1; continue; }

  # HTTPS (TLS + ca-certificates)
  run_test "$image" "$v" "curl -sSf -o /dev/null https://example.com" "HTTPS works" || { FAILED=1; continue; }
done

# OCI labels (host-side check): version, title, description, vendor
for v in "${VERSIONS[@]}"; do
  image="${IMAGE_BASE}:${v}"
  docker image inspect "$image" &>/dev/null || continue
  label_version="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.version"}}' 2>/dev/null)" || true
  label_title="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.title"}}' 2>/dev/null)" || true
  label_desc="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.description"}}' 2>/dev/null)" || true
  label_vendor="$(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.vendor"}}' 2>/dev/null)" || true
  if [[ "$label_version" != "$v" ]]; then
    echo "FAIL: $image — OCI version label expected '$v', got '$label_version'"
    FAILED=1
  else
    echo "OK: $image — OCI version label set"
  fi
  for name in title description vendor; do
    val="label_$name"
    val="${!val}"
    if [[ -z "$val" ]]; then
      echo "FAIL: $image — OCI label org.opencontainers.image.$name missing or empty"
      FAILED=1
    else
      echo "OK: $image — OCI $name label set"
    fi
  done
done

if [[ $FAILED -ne 0 ]]; then
  echo "Some tests failed."
  exit 1
fi
echo "All tests passed."
