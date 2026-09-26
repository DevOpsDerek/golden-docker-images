# Golden Windows Server LTSC Docker Images

Minimal, security-patched Docker base images for **Windows Server LTSC** (Server Core): ltsc2022 and ltsc2025. Use these as a consistent Windows base for your applications.

**Requires:** Windows host with Docker set to **Windows containers** (e.g. Docker Desktop → “Switch to Windows containers”).

## What’s in a “golden” image

- **Official base**: `mcr.microsoft.com/windows/servercore:ltsc20xx`
- **Secure defaults**: TLS 1.2 enabled for Client and Server
- **OCI labels**: version, title, description, vendor for versioning

## Images

| Version   | Directory   |
|-----------|-------------|
| ltsc2022  | `ltsc2022/` |
| ltsc2025  | `ltsc2025/` |

## Build

**All versions (default tag `windows-golden:<version>`):**

```powershell
./build.ps1
```

**With a custom registry/repo:**

```powershell
./build.ps1 ghcr.io/myorg/windows-golden
```

**Using Make (on Windows with make installed, or WSL):**

```bash
make build-all
make build-ltsc2022
make build-all REGISTRY=ghcr.io/myorg/windows-golden
make push-all REGISTRY=ghcr.io/myorg/windows-golden
```

## Use as base image

In your app’s Dockerfile (build on Windows with Windows containers):

```dockerfile
FROM ghcr.io/myorg/windows-golden:ltsc2022
# or locally: FROM windows-golden:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]
RUN Install-WindowsFeature -Name Web-Server
COPY . C:\app
WORKDIR C:\app
CMD ["powershell"]
```

## Tests

Tests verify each image: container runs, PowerShell and OS registry present, TLS 1.2 keys set, and OCI labels.

```powershell
make test
# or (images must already be built)
./tests/test.ps1
./tests/test.ps1 ghcr.io/myorg/windows-golden
```

CI runs these tests after every build (workflow at repo root: [.github/workflows/build-windows.yml](../.github/workflows/build-windows.yml)).

## Security

Images are scanned in CI using [Trivy](https://github.com/aquasecurity/trivy). The build fails if any **CRITICAL** or **HIGH** severity issues with an available fix are found.

**Scan locally** (after building, on Windows):

```bash
make scan
```

Or run Trivy Windows binary against each tag.

## Linting

Linters run on Dockerfiles (Hadolint) and workflow YAML (yamllint). Config lives at the [repo root](../).

```bash
make lint
```

From repo root, `pre-commit run --all-files` also lints these files.

## License

Use and modify as you like.
