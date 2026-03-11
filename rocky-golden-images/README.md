# Golden Rocky Linux Docker Images

Minimal, security-patched Docker base images for **Rocky Linux** (RHEL-compatible). Use these for workloads that need a Red Hat–ecosystem base.

## What's in a "golden" image

- **Official base**: `rockylinux:8` or `rockylinux:9`
- **Security updates**: `dnf -y update` at build time
- **Minimal extras**: `ca-certificates`, `curl` for HTTPS and scripting
- **Small layers**: dnf cache cleaned; OCI labels for versioning

## Images

| Version | Directory |
|---------|-----------|
| Rocky Linux 8 | `8/` |
| Rocky Linux 9 | `9/` |

## Build

**All versions (default tag `rocky-golden:<version>`):**

```bash
./build.sh
# or
make
```

**With a custom registry/repo:**

```bash
./build.sh ghcr.io/myorg/rocky-golden
```

## Use as base image

```dockerfile
FROM ghcr.io/myorg/rocky-golden:9
RUN dnf -y install your-packages && dnf clean all
```

## Tests

```bash
make test
# or (images must already be built)
./tests/test.sh rocky-golden
```

CI runs these tests (workflow at repo root: [.github/workflows/build-rocky.yml](../.github/workflows/build-rocky.yml)).

## Security

Images are scanned with Trivy in CI. Scan locally after building: `make scan`.

## Linting

Config and CI live at the [repo root](../). Run `make lint` from this folder.
