# Windows Server Core golden images

Exactly two Microsoft Container Registry bases are supported:

| Image | Base | Build host / GitHub runner |
|-------|------|----------------------------|
| `windows-golden:ltsc2022` | `mcr.microsoft.com/windows/servercore:ltsc2022` | Windows Server 2022 / `windows-2022` |
| `windows-golden:ltsc2025` | `mcr.microsoft.com/windows/servercore:ltsc2025` | Windows Server 2025 / `windows-2025` |

These images inherit the current upstream Server Core base. Rebuild with `--pull` to incorporate Microsoft's latest patched base; there is no extra software or registry configuration. A new version of the base does **not** retroactively patch an image already built. Ensure the Windows host and container versions match for process isolation.

## Local build and test

Use Docker with **Windows containers**, PowerShell 7 (`pwsh`), and a host matching the selected LTSC release. From the repository root:

```powershell
make test-windows WINDOWS_VERSION=ltsc2022
make scan-windows WINDOWS_VERSION=ltsc2022
```

If Make is unavailable, run the same operations from `windows-golden-images/`:

```powershell
./build.ps1 -Version ltsc2022
./tests/test.ps1 -Version ltsc2022
trivy image --image-src docker --scanners vuln --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed windows-golden:ltsc2022
docker run --rm --isolation=process windows-golden:ltsc2022 powershell.exe -NoProfile
```

Substitute `ltsc2025` on a Windows Server 2025 host. The test checks the Windows OS build (20348 or 26100), process-isolated startup and OCI labels. Install the **Windows Trivy CLI** for a local scan; do not use the Linux Trivy Docker image or mount `/var/run/docker.sock` on a Windows host. Trivy's image scan is a useful gate for detected HIGH/CRITICAL vulnerabilities, **not** comprehensive evidence that the Windows OS base has no vulnerabilities: assess Microsoft's Windows container servicing advisories separately before production use.

## Manual workflow and publication

Run [Build Windows Golden Image](../.github/workflows/build-windows.yml) from GitHub Actions, select **one** version, and leave `publish` **false** for validation. The selected GitHub-hosted Windows runner builds with the latest base, executes tests, then scans with a pinned Windows Trivy executable. No Windows build, scan, or publish runs on a push, pull request, or schedule; the Linux lint workflow checks Dockerfiles and workflow controls without a Windows runner.

Only a dispatch **from `main`** with `publish=true` pushes the validated image to `ghcr.io/<lowercase-owner>/windows-golden:<selected-version>`. No other registries, credentials, or scheduled Windows jobs are configured. The version tag is mutable; resolve and record the published digest for deployment, per [the promotion guidance](../docs/supply-chain-golden-path.md). No Windows SBOM, provenance, or signature is produced by this workflow.

Windows container layers are large, and GitHub-hosted Windows jobs and scanner downloads consume resources. Run one selected version only when needed (for example after a Microsoft servicing release), review the scan and servicing advisories, then deliberately opt in to publication.
