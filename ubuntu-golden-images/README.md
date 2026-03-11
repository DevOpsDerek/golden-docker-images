# Golden Ubuntu LTS Docker Images

Minimal, security-patched Docker base images for the **last 4 Ubuntu LTS releases**: 18.04, 20.04, 22.04, and 24.04. Use these as a consistent, maintained foundation for your applications.

## What’s in a “golden” image

- **Official base**: `ubuntu:<version>` (e.g. `ubuntu:22.04`)
- **Security updates**: `apt-get update && apt-get upgrade -y` at build time
- **Minimal extras**: `ca-certificates`, `curl` for HTTPS and scripting
- **Small layers**: apt cache cleaned; OCI labels for versioning

## Images

| Version   | Codename       | Directory |
|----------|----------------|-----------|
| 18.04 LTS | Bionic Beaver  | `18.04/`  |
| 20.04 LTS | Focal Fossa    | `20.04/`  |
| 22.04 LTS | Jammy Jellyfish| `22.04/`  |
| 24.04 LTS | Noble Numbat   | `24.04/`  |

## Build

**All versions (default tag `ubuntu-golden:<version>`):**

```bash
./build.sh
```

**With a custom registry/repo:**

```bash
./build.sh ghcr.io/myorg/ubuntu-golden
```

**Using Make:**

```bash
# Build all
make build-all

# Build one (e.g. 22.04)
make build-22.04

# Custom registry
make build-all REGISTRY=ghcr.io/myorg/ubuntu-golden

# Build and push
make push-all REGISTRY=ghcr.io/myorg/ubuntu-golden
```

## Use as base image

In your app’s Dockerfile:

```dockerfile
FROM ghcr.io/myorg/ubuntu-golden:22.04
# or locally: FROM ubuntu-golden:22.04

RUN apt-get update && apt-get install -y your-packages
COPY . /app
WORKDIR /app
CMD ["./run.sh"]
```

## Tests

Tests verify each image: correct Ubuntu version, presence of `curl` and `ca-certificates`, cleaned apt lists, and OCI labels.

**Run tests (builds images first):**

```bash
make test
```

**Run tests only (images must already be built):**

```bash
./tests/test.sh
./tests/test.sh ghcr.io/myorg/ubuntu-golden   # custom image name
```

CI runs these tests after every build (see `.github/workflows/build.yml`).

## Linting

Linters run on shell scripts (ShellCheck), Dockerfiles (Hadolint), and YAML (yamllint). CI runs them on every push and PR (`.github/workflows/lint.yml`).

**Run locally:**

```bash
make lint
# or
./scripts/lint.sh
```

### Pre-commit

Linting also runs as **pre-commit** hooks so only staged files are checked before each commit.

**One-time setup:**

```bash
pip install pre-commit
pre-commit install
```

After that, `git commit` will run ShellCheck, Hadolint, and yamllint on staged files (plus basic checks: trailing whitespace, end-of-file, YAML syntax). To run the same hooks on the whole repo without committing:

```bash
pre-commit run --all-files
# or
make pre-commit
```

Pre-commit requires the same linters to be installed (ShellCheck, Hadolint, yamllint). Config: `.pre-commit-config.yaml`.

**Install linters (macOS):**

```bash
brew install shellcheck hadolint yamllint
```

**Install (Ubuntu/Debian):**

```bash
sudo apt-get install shellcheck yamllint
# hadolint: download from https://github.com/hadolint/hadolint/releases or run via Docker
docker run --rm -v "$PWD:/mnt" -w /mnt hadolint/hadolint hadolint 18.04/Dockerfile
```

Config: `.hadolint.yaml`, `.yamllint.yml`.

## Customizing a golden image

Each version lives in its own directory (e.g. `22.04/Dockerfile`). You can:

- Add more packages in the `apt-get install` block
- Uncomment the `useradd` / `USER app` lines to run as non-root
- Add env vars, volumes, or entrypoints as needed

Rebuild with `./build.sh` or `make build-22.04` after changes.

## Requirements

- Docker (or a Docker-compatible engine)
- Bash (for `build.sh` and scripts); Make is optional
- For linting: ShellCheck, Hadolint, yamllint (see [Linting](#linting))
- For pre-commit hooks: [pre-commit](https://pre-commit.com/) (`pip install pre-commit`)

## License

Use and modify as you like. Ubuntu is a trademark of Canonical Ltd.
