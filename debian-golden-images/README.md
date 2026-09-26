# Golden Debian Docker Images

Minimal, security-patched Docker base images for **Debian** (slim). Use these as a consistent, small foundation for applications that prefer Debian over Ubuntu.

## What's in a "golden" image

- **Official base**: `debian:<codename>-slim` for supported releases and `debian/eol:<codename>-slim` for upstream-EOL releases
- **Security updates**: `apt-get update && apt-get upgrade -y` at build time
- **Minimal extras**: `ca-certificates`, `curl` for HTTPS and scripting
- **Small layers**: apt cache cleaned; OCI labels for versioning

## Images

| Version | Directory   |
|---------|-------------|
| Bullseye (11, archived upstream) | `bullseye/` |
| Bookworm (12) | `bookworm/` |

## Build

**All versions (default tag `debian-golden:<codename>`):**

```bash
./build.sh
# or
make
```

**With a custom registry/repo:**

```bash
./build.sh ghcr.io/myorg/debian-golden
```

## Use as base image

```dockerfile
FROM ghcr.io/myorg/debian-golden:bookworm
RUN apt-get update && apt-get install -y your-packages
```

## Tests

```bash
make test
# or (images must already be built)
./tests/test.sh debian-golden
```

CI runs these tests (workflow at repo root: [.github/workflows/build-debian.yml](../.github/workflows/build-debian.yml)).

Bullseye is upstream-EOL, so its Dockerfile uses Debian's official `debian/eol:bullseye-slim` base image and re-enables the bundled snapshot.debian.org sources for reproducible legacy rebuilds.

## Security

Images are scanned with Trivy in CI. Scan locally after building: `make scan`.

## Linting

Config and CI live at the [repo root](../). Run `make lint` from this folder.
