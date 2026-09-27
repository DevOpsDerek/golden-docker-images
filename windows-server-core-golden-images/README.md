# Golden Windows Server Core Docker Images

Cost-conscious Windows Server Core golden images for the currently supported LTSC releases:

- `ltsc2022` (`mcr.microsoft.com/windows/servercore:ltsc2022`)
- `ltsc2025` (`mcr.microsoft.com/windows/servercore:ltsc2025`)

There is no Windows Server 2026 LTSC container base tag in MCR.

## Build

```bash
cd windows-server-core-golden-images

# Build both LTSC variants
make build-all

# Build one LTSC variant
make build-ltsc2022
make build-ltsc2025
```

## Test

```bash
cd windows-server-core-golden-images

# Static checks (works on Linux CI too)
make test

# Runtime checks for one built LTSC variant (requires compatible Windows Docker host)
make test TARGET_VERSION=ltsc2022
```

## Lint

```bash
cd windows-server-core-golden-images
make lint
```

## Vulnerability scan

```bash
cd windows-server-core-golden-images

# Focused scan for one built LTSC variant
make scan TARGET_VERSION=ltsc2025
```

## Manual GitHub Actions workflow (cost-conscious)

Use [`.github/workflows/build-windows-server-core.yml`](../.github/workflows/build-windows-server-core.yml) to build one LTSC version on demand:

- Trigger: `workflow_dispatch` only (no push/PR/schedule Windows builds)
- Input `version`: select `ltsc2022` or `ltsc2025`
- Input `publish`: defaults to `false`; set to `true` only when maintainers explicitly want to push to GHCR

This avoids recurring Windows runner and image-scanning cost while still allowing full validation when needed.
