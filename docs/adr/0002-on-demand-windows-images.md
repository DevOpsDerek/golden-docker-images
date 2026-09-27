# ADR 0002: On-demand Windows Server Core images

- Status: Accepted
- Date: 2026-09-27

## Context

Windows Server Core image builds are large and require compatible Windows container hosts. Running a two-version matrix on every Linux-family CI event or monthly schedule would consume Windows runner and scanning resources even when no Windows image is needed.

## Decision

Support only the official Server Core `ltsc2022` and `ltsc2025` bases. Build, test, and scan one version per manual workflow dispatch on `windows-2022` or `windows-2025`, respectively. Keep the existing Linux default build/test and monthly workflows unchanged, and run compatible Windows static checks in Linux lint CI. Publish to GHCR only when `publish=true` is explicitly selected on `main`; default to validation without publication.

The image uses the patched upstream base on each `--pull` rebuild, without custom package installation. Trivy's Windows image scan is not proof of complete Windows OS vulnerability coverage; Microsoft servicing advisories must also be checked. Do not claim Windows SBOMs, signatures, or attestations from this workflow. Published version tags remain mutable and digest-based promotion follows ADR 0001.

## Consequences

There is no automatic Windows patch rebuild or publication. Maintainers must dispatch each version when needed, review servicing/security results, and opt in to publishing only after validation. No always-on or self-hosted runner is required.
