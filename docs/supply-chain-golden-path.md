# Golden image supply-chain golden path

This document records the repository's current supply-chain expectations without changing the existing image build and publish behavior.

## Ownership and cadence assumptions

> **Maintainer confirmation required:** the repository does not currently declare formal owners or an approval group in-code, so the items below are working assumptions for review rather than asserted facts.

- Assume the repository maintainer(s) own version additions/removals, base-image exceptions, and emergency rebuild decisions until a maintainer confirms a permanent owner list.
- Assume the monthly scheduled workflows are the normal refresh cadence because each Linux image workflow already rebuilds on the first day of every month at 00:00 UTC.
- Assume out-of-band rebuilds are expected whenever an upstream base image ships a fix for a relevant vulnerability or CI starts failing on a fixable HIGH/CRITICAL issue.

## Supported upstream base images

The repository currently builds the following upstream base-image references:

| Family | Golden image versions | Upstream base references |
|--------|------------------------|--------------------------|
| Alpine | 3.17, 3.18, 3.19, 3.20 | `alpine:3.17`, `alpine:3.18`, `alpine:3.19`, `alpine:3.20` |
| Ubuntu LTS | 18.04, 20.04, 22.04, 24.04 | `ubuntu:18.04`, `ubuntu:20.04`, `ubuntu:22.04`, `ubuntu:24.04` |
| Debian | bookworm | `debian:bookworm-slim` |
| Rocky Linux | 8, 9 | `rockylinux:8`, `rockylinux:9` |

Support in this repository is limited to the versions that still exist as directories and are still intentionally built in CI. When an upstream version reaches end of life, the expected maintenance action is to remove or replace that version in a normal reviewed pull request rather than silently leave it in place.

## Lifecycle and exception process

- Monthly scheduled builds provide the baseline refresh path.
- Pull requests validate build, runtime smoke tests, vulnerability scanning, and SBOM generation before merge.
- Merges to the default branch remain the publish trigger for mutable version tags and scheduled CalVer aliases.
- Any request to keep an image after upstream end of life, skip a required check, or ship with a known unfixed vulnerability should be tracked in a GitHub issue or pull request with:
  - the requested exception and affected image tags
  - the reason the exception is needed
  - compensating controls
  - an expiry/review date
  - the maintainer approver once ownership is confirmed

## Promotion and deployment identity

Promotion between environments should use an immutable digest such as `ghcr.io/<owner>/ubuntu-golden:24.04@sha256:<digest>` or the digest alone after the image is resolved in the target registry.

Mutable tags are still useful, but only as convenience aliases:

- family/version tags (`3.20`, `22.04`, `bookworm`, `9`)
- scheduled CalVer tags (`3.20-2026-09`, `bookworm-2026-09`)

Consumers should record the digest that passed validation, approval, and deployment promotion. Re-tagging a digest for convenience is acceptable, but the digest is the identity that should appear in deployment manifests, release notes, and rollback procedures.

## SBOM, provenance, signing, and verification

- CI now generates SPDX JSON SBOM artifacts for each workflow run by scanning the built local images with Syft.
- The repository does **not** currently publish build provenance attestations.
- The repository does **not** currently sign images or SBOMs.

Those two gaps are intentional for now: the current workflows build and optionally push images, but the repository does not yet declare approved keyless signing, trusted identity verification, or attestation publication requirements. Maintainer follow-up is required before enabling provenance attestations or signatures so that the verification path is explicit and supportable.

Until then, the practical verification baseline is:

1. image build succeeds
2. runtime smoke tests pass
3. Trivy finds no fixable HIGH/CRITICAL vulnerabilities
4. the workflow produces an SBOM artifact for review/archive

## Response to vulnerable base images

When an upstream base image or a golden image scan reports a vulnerability:

1. rebuild the affected image after the upstream fix is available
2. rerun the repository tests and Trivy scan
3. promote the rebuilt image by digest, not by mutable tag alone
4. if no fix is available, document the exception in GitHub and keep the image under explicit review until the exception expires or a fix ships

Because the CI scan uses `--ignore-unfixed`, fixable HIGH/CRITICAL vulnerabilities are blocking, while unfixed issues still require explicit triage instead of silent acceptance.

## External follow-up prerequisites

- Confirm the long-term owner/approver list for this repository.
- Decide whether GitHub Artifact Attestations, registry-native provenance, or another attestation path is the supported provenance mechanism.
- Decide whether Sigstore/cosign keyless signing is the supported signing path and document the exact verification command once enabled.
