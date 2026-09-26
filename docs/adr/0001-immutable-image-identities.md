# ADR 0001: Immutable image identities for promotion

- Status: Accepted
- Date: 2026-09-26

## Context

The repository already builds and publishes version tags such as `3.20`, `22.04`, `bookworm`, and `9`, plus scheduled CalVer aliases such as `22.04-2026-09`. Those tags are useful for discovery, but registry tags remain mutable even when the workflow intends to keep them stable.

BG-004 requires stronger guidance for image promotion, supply-chain evidence, and signing without claiming repository capabilities that are not actually implemented or verified by the workflows.

## Decision

1. **Immutable digests are the promotion and deployment identity.**
   - CI may continue producing version tags and CalVer aliases.
   - Promotion records, deployment manifests, and rollback references should use the resolved digest of the approved image.
2. **CI produces SBOM artifacts now, but not provenance attestations.**
   - The workflows generate SPDX JSON SBOM artifacts for built images because that is compatible with the current local-image workflow pattern.
   - The repository does not claim build provenance attestations until maintainers choose and enable a supported publication and verification path.
3. **Image signing is deferred until verification requirements are explicit.**
   - No image signatures are published by this repository today.
   - A future change may enable signing only after maintainers confirm the trusted identity, registry support, and verification commands consumers must use.

## Consequences

- Existing build and publish behavior stays intact.
- Consumers get actionable guidance now: build/test/scan/SBOM today, digest-based promotion immediately, and signing/provenance only after repository support exists.
- Future provenance or signing work must update this ADR and the supply-chain documentation together so the repository never claims stronger evidence than the workflows actually provide.
