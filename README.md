# Golden Docker Images

Minimal, security-patched Docker base images for **Alpine**, **Ubuntu LTS**, **Debian**, and **Rocky Linux**. Each family is built, tested, and scanned for vulnerabilities in CI. Use these as a consistent foundation for your applications.

## Image families

| Family | Versions | Directory |
|--------|----------|-----------|
| **Alpine** | 3.17, 3.18, 3.19, 3.20 | [alpine-golden-images/](alpine-golden-images/) |
| **Ubuntu LTS** | 18.04, 20.04, 22.04, 24.04 | [ubuntu-golden-images/](ubuntu-golden-images/) |
| **Debian** | bullseye, bookworm | [debian-golden-images/](debian-golden-images/) |
| **Rocky Linux** | 8, 9 | [rocky-golden-images/](rocky-golden-images/) |

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

- **CI:** A single [Lint](.github/workflows/lint.yml) workflow runs ShellCheck, Hadolint, and yamllint on all image families.
- **Local (per family):** From any `*-golden-images/` folder, run `make lint` (or `./scripts/lint.sh`). Linters use the config files in the repo root.

**Install linters (macOS):** `brew install shellcheck hadolint yamllint`

### GitHub Actions (root)

| Workflow | Purpose |
|----------|---------|
| [build-alpine.yml](.github/workflows/build-alpine.yml) | Build, test, Trivy scan, optional push for Alpine images |
| [build-ubuntu.yml](.github/workflows/build-ubuntu.yml) | Build, test, Trivy scan, optional push for Ubuntu images |
| [build-debian.yml](.github/workflows/build-debian.yml) | Build, test, Trivy scan, optional push for Debian images |
| [build-rocky.yml](.github/workflows/build-rocky.yml) | Build, test, Trivy scan, optional push for Rocky Linux images |
| [lint.yml](.github/workflows/lint.yml) | Lint all families on push/PR |

Workflows run from the repo root and use `working-directory` so each build runs in its folder.

**Monthly schedule:** On the first day of each month (00:00 UTC), all build workflows run and push images. In addition to the version tag, images get a [CalVer](https://calver.org/) tag with year and month (e.g. `3.18-2025-03`, `bookworm-2025-03`, `9-2025-03`).

### Security (Trivy)

All build workflows run [Trivy](https://github.com/aquasecurity/trivy) and fail on **CRITICAL** or **HIGH** vulnerabilities with an available fix. To scan locally after building, run `make scan` from the relevant family folder.

## Quick start

**Build and test all image families (from repo root):**

```bash
make
```

This builds and tests Alpine, Ubuntu, Debian, and Rocky. Equivalent to `make all` or `make test-all`.

**Build and test one family:**

```bash
cd alpine-golden-images && make
cd ubuntu-golden-images && make
cd debian-golden-images && make
cd rocky-golden-images && make
```

**Other root targets:**

```bash
make build-all   # build all images (all families)
make scan-all    # Trivy scan all built images (run after make build-all)
make lint        # run ShellCheck, Hadolint, yamllint for all families
make clean       # remove built images from all families
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
