# Golden Docker Images

Minimal, security-patched Docker base images for **Alpine** and **Ubuntu LTS**. Each family is built, tested, and scanned for vulnerabilities in CI. Use these as a consistent foundation for your applications.

## Image families

| Family | Versions | Directory |
|--------|----------|-----------|
| **Alpine** | 3.17, 3.18, 3.19, 3.20 | [alpine-golden-images/](alpine-golden-images/) |
| **Ubuntu LTS** | 18.04, 20.04, 22.04, 24.04 | [ubuntu-golden-images/](ubuntu-golden-images/) |

See each folder’s README for build, test, and usage instructions.

## Shared configuration (repo root)

Linting and CI are configured once at the repo root and apply to both families.

### Pre-commit

One [pre-commit](https://pre-commit.com/) config at root runs on the whole repo (shell scripts, Dockerfiles, YAML).

**One-time setup:**

```bash
pip install pre-commit
pre-commit install
```

**Run on all files:**

```bash
pre-commit run --all-files
```

Hooks use root config files: [.pre-commit-config.yaml](.pre-commit-config.yaml), [.hadolint.yaml](.hadolint.yaml), [.yamllint.yml](.yamllint.yml).

### Linting (ShellCheck, Hadolint, yamllint)

- **CI:** A single [Lint](.github/workflows/lint.yml) workflow runs ShellCheck, Hadolint, and yamllint on both `alpine-golden-images/` and `ubuntu-golden-images/`.
- **Local (per family):** From `alpine-golden-images/` or `ubuntu-golden-images/`, run `make lint` (or `./scripts/lint.sh`). Linters use the config files in the repo root.

**Install linters (macOS):** `brew install shellcheck hadolint yamllint`

### GitHub Actions (root)

| Workflow | Purpose |
|----------|---------|
| [build-alpine.yml](.github/workflows/build-alpine.yml) | Build, test, Trivy scan, optional push for Alpine images |
| [build-ubuntu.yml](.github/workflows/build-ubuntu.yml) | Build, test, Trivy scan, optional push for Ubuntu images |
| [lint.yml](.github/workflows/lint.yml) | Lint both families on push/PR |

Workflows run from the repo root and use `working-directory` so each build runs in its folder.

**Monthly schedule:** On the first day of each month (00:00 UTC), both build workflows run and push images to the registry (default: `ghcr.io/<owner>/alpine-golden` and `ghcr.io/<owner>/ubuntu-golden`). In addition to the version tag (e.g. `3.18`, `22.04`), images get a [CalVer](https://calver.org/) tag with year and month: e.g. `3.18-2025-03`, `22.04-2025-03`.

### Security (Trivy)

Both build workflows run [Trivy](https://github.com/aquasecurity/trivy) and fail on **CRITICAL** or **HIGH** vulnerabilities with an available fix. To scan locally after building, run `make scan` from the relevant folder (e.g. `alpine-golden-images/` or `ubuntu-golden-images/`).

## Quick start

**Build and test all image families (from repo root):**

```bash
make
```

This builds and tests Alpine, then Ubuntu. Equivalent to `make all` or `make test-all`.

**Build and test one family:**

```bash
cd alpine-golden-images && make
# or
cd ubuntu-golden-images && make
```

**Other root targets:**

```bash
make build-all   # build all images (both families)
make scan-all    # Trivy scan all built images (run after make build-all)
make lint        # run ShellCheck, Hadolint, yamllint for both families
make clean       # remove built images from both families
```

**Lint the whole repo (from root):**

```bash
pre-commit run --all-files
```

**Lint one family:**

```bash
cd alpine-golden-images && make lint
```

## Requirements

- Docker
- Bash (for scripts); Make optional
- For linting: ShellCheck, Hadolint, yamllint
- For pre-commit: `pip install pre-commit`

## License

Use and modify as you like.
