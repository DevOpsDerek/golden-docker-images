# Golden Alpine Docker Images

Minimal, security-patched Docker base images for **recent Alpine Linux releases**: 3.17, 3.18, 3.19, and 3.20. Use these as a small, consistent foundation for your applications.

## What’s in a “golden” image

- **Official base**: `alpine:<version>` (e.g. `alpine:3.20`)
- **Security updates**: `apk update && apk upgrade` at build time
- **Minimal extras**: `ca-certificates`, `curl` for HTTPS and scripting
- **Small layers**: `--no-cache` so no apk cache left behind; OCI labels for versioning

## Images

| Version | Directory |
|---------|-----------|
| 3.17    | `3.17/`   |
| 3.18    | `3.18/`   |
| 3.19    | `3.19/`   |
| 3.20    | `3.20/`   |

## Build

**All versions (default tag `alpine-golden:<version>`):**

```bash
./build.sh
```

**With a custom registry/repo:**

```bash
./build.sh ghcr.io/myorg/alpine-golden
```

**Using Make:**

```bash
make build-all
make build-3.18
make build-all REGISTRY=ghcr.io/myorg/alpine-golden
make push-all REGISTRY=ghcr.io/myorg/alpine-golden
```

## Use as base image

In your app’s Dockerfile:

```dockerfile
FROM ghcr.io/myorg/alpine-golden:3.20
# or locally: FROM alpine-golden:3.20

RUN apk add --no-cache your-packages
COPY . /app
WORKDIR /app
CMD ["./run.sh"]
```

Note: Alpine uses **/bin/sh** by default (not bash). Use `sh` in scripts or add `RUN apk add --no-cache bash` if you need bash.

## Tests

Tests verify each image: correct Alpine version, presence of `curl` and `ca-certificates`, cleaned apk cache, and OCI labels.

```bash
make test
# or (images must already be built)
./tests/test.sh
./tests/test.sh ghcr.io/myorg/alpine-golden
```

CI runs these tests after every build (workflow at repo root: [.github/workflows/build-alpine.yml](../.github/workflows/build-alpine.yml)).

## Security

Images are scanned for known vulnerabilities in CI using [Trivy](https://github.com/aquasecurity/trivy). The build fails if any **CRITICAL** or **HIGH** severity issues with an available fix are found (`--ignore-unfixed`).

**Scan locally** (after building):

```bash
make scan
# or manually for each version:
for v in 3.17 3.18 3.19 3.20; do
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed alpine-golden:$v
done
```

**Full report** (no exit-code failure):

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image alpine-golden:3.20
```

Keeping images secure: use `apk upgrade` at build time (already in the Dockerfiles), rebuild and redeploy when the base Alpine image or Trivy reports new fixes, and pin to a digest in production if you need reproducibility (e.g. `alpine:3.20@sha256:...`).

## Linting

Linters run on shell scripts (ShellCheck), Dockerfiles (Hadolint), and YAML (yamllint). Config (`.hadolint.yaml`, `.yamllint.yml`) and CI (`.github/workflows/lint.yml`) live at the [repo root](../).

```bash
make lint
./scripts/lint.sh
```

### Pre-commit

Linting also runs as **pre-commit** hooks so only staged files are checked before each commit.

**One-time setup:**

```bash
pip install pre-commit
pre-commit install
```

Run on the whole repo:

```bash
pre-commit run --all-files
make pre-commit
```

**Install linters (macOS):** `brew install shellcheck hadolint yamllint`  
**Ubuntu/Debian:** `sudo apt-get install shellcheck yamllint`; run Hadolint via Docker (see [Lint workflow](.github/workflows/lint.yml)).

Config: `.hadolint.yaml`, `.yamllint.yml`, `.pre-commit-config.yaml` (at [repo root](../)).

## Customizing a golden image

Each version lives in its own directory (e.g. `3.20/Dockerfile`). You can add packages in the `apk add` line, uncomment the `adduser` / `USER app` lines to run as non-root, or add env vars and entrypoints. Rebuild with `./build.sh` or `make build-3.20` after changes.

## Requirements

- Docker (or a Docker-compatible engine)
- Bash (for scripts); Make is optional
- For linting: ShellCheck, Hadolint, yamllint
- For pre-commit: `pip install pre-commit`

## License

Use and modify as you like.
