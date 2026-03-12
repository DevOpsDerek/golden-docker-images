# Golden Docker Images

Minimal, security-patched Docker base images for **Linux** (Alpine, Ubuntu LTS, Debian, Rocky) and **Windows** (Windows Server LTSC). Each family is built, tested, and scanned for vulnerabilities in CI. Use these as a consistent foundation for your applications.

## Linux image families

| Family | Versions | Directory |
|--------|----------|-----------|
| **Alpine** | 3.17, 3.18, 3.19, 3.20 | [alpine-golden-images/](alpine-golden-images/) |
| **Ubuntu LTS** | 18.04, 20.04, 22.04, 24.04 | [ubuntu-golden-images/](ubuntu-golden-images/) |
| **Debian** | bullseye, bookworm | [debian-golden-images/](debian-golden-images/) |
| **Rocky Linux** | 8, 9 | [rocky-golden-images/](rocky-golden-images/) |

## Windows image families

| Family | Versions | Directory |
|--------|----------|-----------|
| **Windows Server LTSC** | ltsc2019, ltsc2022, ltsc2025 (Server Core) | [windows-golden-images/](windows-golden-images/) |

See each folder’s README for build, test, and usage instructions.

## Shared configuration (repo root)

Linting and CI are configured once at the repo root and apply to all families (Linux and Windows).

### Pre-commit

One [pre-commit](https://pre-commit.com/) config at root runs on the whole repo (shell scripts, Dockerfiles, YAML). ShellCheck, Hadolint, and yamllint run **inside Docker** — you only need Docker and pre-commit installed locally.

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

- **CI:** The [Lint](.github/workflows/lint.yml) workflow runs **pre-commit** (`pre-commit run --all-files`), so CI uses the same hooks as local (ShellCheck, Hadolint, yamllint, etc.).
- **Local (per family):** From any `*-golden-images/` folder, run `make lint` (or `./scripts/lint.sh`). Linters use the config files in the repo root.

**Install linters (macOS):** `brew install shellcheck hadolint yamllint`

### GitHub Actions (root)

| Workflow | Purpose |
|----------|---------|
| [build-alpine.yml](.github/workflows/build-alpine.yml) | Build, test, Trivy scan, push for **Alpine** (Linux) |
| [build-ubuntu.yml](.github/workflows/build-ubuntu.yml) | Build, test, Trivy scan, push for **Ubuntu** (Linux) |
| [build-debian.yml](.github/workflows/build-debian.yml) | Build, test, Trivy scan, push for **Debian** (Linux) |
| [build-rocky.yml](.github/workflows/build-rocky.yml) | Build, test, Trivy scan, push for **Rocky** (Linux) |
| [build-windows.yml](.github/workflows/build-windows.yml) | Build, test, Trivy scan, push for **Windows Server LTSC** (Windows runner) |
| [lint.yml](.github/workflows/lint.yml) | Run pre-commit (all hooks) on push/PR |

Linux workflows run on `ubuntu-24.04`; the Windows workflow runs on `windows-latest` (Windows containers). Each uses `working-directory` so the build runs in its folder.

**Monthly schedule:** On the first day of each month (00:00 UTC), all build workflows run and push images. Version tags plus [CalVer](https://calver.org/) tags (e.g. `3.18-2025-03`, `ltsc2022-2025-03`) are applied.

### Publishing images

CI can push images to a container registry when you enable it. Options:

| Registry | How to use |
|----------|------------|
| **GitHub Container Registry (ghcr.io)** | When push runs, images are **always** pushed to GHCR at `ghcr.io/<repo_owner>/<family>-golden` using `GITHUB_TOKEN`. Override with repo variable `REGISTRY_GHCR` (e.g. `ghcr.io/myorg/alpine-golden`). |
| **Docker Hub (in addition to GHCR)** | Set repo **variable** `DOCKERHUB_NAMESPACE=devopsd` (or your username). Add repo **secrets**: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`. Images are then pushed to **both** GHCR and `docker.io/<DOCKERHUB_NAMESPACE>/<family>-golden`. |
| **AWS ECR** | Set `REGISTRY=<account>.dkr.ecr.<region>.amazonaws.com/your-repo`. Use [configure-aws-credentials](https://github.com/aws-actions/amazon-ecr-login) and `docker login` to ECR in the workflow; store AWS credentials in repo secrets. |
| **Google Artifact Registry** | Set `REGISTRY=<region>-docker.pkg.dev/<project>/<repo>/<image>`. Use [google-github-actions/auth](https://github.com/google-github-actions/auth) and `docker login` to the registry; use a service account key or Workload Identity. |
| **Azure ACR** | Set `REGISTRY=yourregistry.azurecr.io/your-repo`. Use [azure/docker-login](https://github.com/Azure/docker-login) with an ACR service principal stored in secrets. |
| **Quay.io** | Set `REGISTRY=quay.io/yourorg/alpine-golden`. Add secrets for Quay username and token; `docker login quay.io` in the push step. |
| **Self-hosted (Harbor, etc.)** | Set `REGISTRY=your-registry.example.com/your-repo`. Add secrets for username/password or token and run `docker login $REGISTRY` before push. |

**When push runs:** **Always** on merge (or push) to the repo’s **default branch** and on the **monthly schedule** (1st of month). PRs and pushes to other branches do not publish. When it runs, images go to GHCR; if `DOCKERHUB_NAMESPACE` is set, they are also pushed to Docker Hub.

**Local push:** From a family folder, e.g. `cd alpine-golden-images && make push` (uses `REGISTRY` env or default; you must `docker login` first).

### Security (Trivy)

All build workflows run [Trivy](https://github.com/aquasecurity/trivy) and fail on **CRITICAL** or **HIGH** vulnerabilities with an available fix. To scan locally after building, run `make scan` from the relevant family folder.

## Quick start

**Build and test all Linux families (from repo root):**

```bash
make
```

This builds and tests Alpine, Ubuntu, Debian, and Rocky. Equivalent to `make all` or `make linux-all`.

**Build and test one Linux family:**

```bash
cd alpine-golden-images && make
cd ubuntu-golden-images && make
cd debian-golden-images && make
cd rocky-golden-images && make
```

**Build and test Windows family (on Windows with Docker set to Windows containers):**

```bash
cd windows-golden-images && make
# or: pwsh -File build.ps1 && pwsh -File tests/test.ps1 windows-golden
```

**Other root targets:**

```bash
make linux-all    # build and test all Linux families (default for make)
make windows-all  # build and test Windows family (run on Windows)
make build-all    # build all Linux images only
make scan-all     # Trivy scan all built Linux images (run after make build-all)
make lint         # run linters for all families (Linux + Windows)
make clean        # remove built images from all families
```

**Lint the whole repo (from root):**

```bash
pre-commit run --all-files
```

**Lint one family:**

```bash
cd alpine-golden-images && make lint
cd windows-golden-images && make lint
```

## Requirements

- **Docker**
- **Bash** (for Linux scripts); **Make** optional
- **Linux images:** Build and run on Linux or Docker Desktop (Linux containers).
- **Windows images:** Build and run on **Windows** with Docker set to **Windows containers** (e.g. Docker Desktop with “Switch to Windows containers”).
- For pre-commit: `pip install pre-commit` (Python 3.9+; ShellCheck, Hadolint, yamllint run in containers; no local install needed)
- For `make lint` per family: ShellCheck, Hadolint, yamllint installed locally (or use pre-commit from root)

## License

Use and modify as you like.
