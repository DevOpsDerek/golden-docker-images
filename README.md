# Golden Docker Images

Minimal Docker base images for **Alpine**, **Ubuntu LTS**, **Debian**, **Rocky Linux**, and **Windows Server Core**. Linux families build and scan in CI; Windows builds and scans are on demand to avoid recurring Windows runner costs.

## Image families

| Family | Versions | Directory |
|--------|----------|-----------|
| **Alpine** | 3.17, 3.18, 3.19, 3.20 | [alpine-golden-images/](alpine-golden-images/) |
| **Ubuntu LTS** | 18.04, 20.04, 22.04, 24.04 | [ubuntu-golden-images/](ubuntu-golden-images/) |
| **Debian** | bookworm | [debian-golden-images/](debian-golden-images/) |
| **Rocky Linux** | 8, 9 | [rocky-golden-images/](rocky-golden-images/) |
| **Windows Server Core** | ltsc2022, ltsc2025 | [windows-golden-images/](windows-golden-images/) |

See each folder’s README for build, test, and usage instructions.

## Shared configuration (repo root)

Linting and CI are configured at the repo root for all families.

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
- **Local (Linux families):** From a Linux `*-golden-images/` folder, run `make lint` (or `./scripts/lint.sh`). For Windows Dockerfiles and workflow controls, run `hadolint` and `bash scripts/validate-windows.sh` from the root (also included in `make lint`).

**Install linters (macOS):** `brew install shellcheck hadolint yamllint`

### GitHub Actions (root)

| Workflow | Purpose |
|----------|---------|
| [build-alpine.yml](.github/workflows/build-alpine.yml) | Build, test, Trivy scan, optional push for Alpine images |
| [build-ubuntu.yml](.github/workflows/build-ubuntu.yml) | Build, test, Trivy scan, optional push for Ubuntu images |
| [build-debian.yml](.github/workflows/build-debian.yml) | Build, test, Trivy scan, optional push for Debian images |
| [build-rocky.yml](.github/workflows/build-rocky.yml) | Build, test, Trivy scan, optional push for Rocky Linux images |
| [build-windows.yml](.github/workflows/build-windows.yml) | Manual-only build, test and scan for one selected Windows LTSC version; optional GHCR publication |
| [lint.yml](.github/workflows/lint.yml) | Run pre-commit and Windows static checks on push/PR (Linux runner) |

Workflows run from the repo root and use `working-directory` so each build runs in its folder.

**Monthly schedule:** On the first day of each month (00:00 UTC), the Linux build workflows run and push images. Windows has no schedule, push, or PR build trigger. Linux images also get a [CalVer](https://calver.org/) tag with year and month (e.g. `3.18-2025-03`, `bookworm-2025-03`, `9-2025-03`).

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

**When Linux push runs:** **Always** on merge (or push) to the repo’s **default branch** and on the **monthly schedule** (1st of month). No variable required — push is mandatory for those events. PRs and pushes to other branches do not publish. The “Determine if push should run” step logs why push was skipped when it doesn’t run. When it runs, images go to GHCR; if `DOCKERHUB_NAMESPACE` is set, they are also pushed to Docker Hub. Windows publication instead requires a manual dispatch from `main` with `publish=true`; the default is false.

**Local push:** From a family folder, e.g. `cd alpine-golden-images && make push` (uses `REGISTRY` env or default; you must `docker login` first).

### Security (Trivy)

Build workflows run [Trivy](https://github.com/aquasecurity/trivy) and fail on **CRITICAL** or **HIGH** vulnerabilities with an available fix. Windows scans occur only on manual dispatch; Trivy does not guarantee coverage of Windows OS patch vulnerabilities. To scan a Linux image locally after building, run `make scan` from the relevant family folder.

## Supply-chain hardening

See [docs/supply-chain-golden-path.md](docs/supply-chain-golden-path.md) for image ownership assumptions that need maintainer confirmation, supported upstream base images, lifecycle/cadence guidance, the exception process, promotion guidance, signing expectations, SBOM handling, and the response for vulnerable base images.

The Linux build workflows generate SPDX JSON SBOM artifacts for each built image. The manual Windows workflow does not generate an SBOM; it builds, tests, and scans only. None publish build provenance attestations or signatures yet; those remain maintainer follow-up items until the repository has approved signing/attestation infrastructure and permissions.

For promotion and deployments, treat an **immutable image digest** as the release identity. Version tags such as `22.04`, `bookworm`, or CalVer tags such as `22.04-2026-09` are useful discovery aliases, but they remain mutable registry tags and should not be the final production deployment reference on their own.

The accompanying ADR [docs/adr/0001-immutable-image-identities.md](docs/adr/0001-immutable-image-identities.md) records that design decision for future changes.

## Quick start

**Build and test all Linux image families (from repo root):**

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

For Windows, see [Windows build and test instructions](windows-golden-images/README.md). Use `make test-windows WINDOWS_VERSION=ltsc2022` (or `ltsc2025`) only on a matching Windows container host; this is never part of the default `make` targets.

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
- For pre-commit: `pip install pre-commit` (Python 3.9+; ShellCheck, Hadolint, yamllint run in containers; no local install needed)
- For `make lint` per family: ShellCheck, Hadolint, yamllint installed locally (or use pre-commit from root)

## License

Use and modify as you like.
