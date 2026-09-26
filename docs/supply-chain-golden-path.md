# Golden image supply-chain golden path

This document defines the repository-level supply-chain expectations for golden images.

## Ownership and decision authority

- **Repository owner:** @DevOpsDerek.
- **Image family owners (assumption, maintainer confirmation required):**
  - Alpine: Platform Engineering
  - Ubuntu: Platform Engineering
  - Debian: Platform Engineering
  - Rocky: Platform Engineering
- **Security review owner (assumption, maintainer confirmation required):** Platform Security or equivalent delegated reviewer.

## Supported base images

Supported image families and versions are defined in this repository:

- Alpine: 3.17, 3.18, 3.19, 3.20
- Ubuntu LTS: 18.04, 20.04, 22.04, 24.04
- Debian: bullseye, bookworm
- Rocky Linux: 8, 9

Each family has its own folder (`*-golden-images/`) with Dockerfiles, tests, and scripts.

## Update cadence and rebuild policy

- **Security and dependency updates:** Dockerfiles already apply package updates at build time.
- **Scheduled rebuild cadence:** monthly (`0 0 1 * *`) via GitHub Actions.
- **Additional rebuild triggers:** pull requests, merges to the default branch, and manual dispatch.
- **Cadence ownership assumption (maintainer confirmation required):** monthly rebuilds are sufficient unless urgent vulnerability response requires immediate rebuild and promotion.

## Image lifecycle

1. Build and test image versions in CI.
2. Run vulnerability scanning (Trivy, failing on fixable HIGH/CRITICAL findings).
3. Generate SBOM and build metadata artifacts in CI for each image version.
4. Publish images on approved events (default branch push and schedule).
5. Consume promoted images by immutable digest in deployment systems.
6. Keep mutable tags for discovery/convenience only.

The uploaded Buildx metadata records build results such as image descriptors and
digests. It is build evidence, not a SLSA provenance attestation, and the
workflows do not currently publish or verify provenance attestations.

## Promotion identity and deployment guidance

- **Promotion/deployment identity:** immutable digest references (`image@sha256:...`) are the release identity.
- **Version tags (for example `:3.20`, `:bookworm`, `:9`)** should be treated as convenience aliases.
- **CalVer tags** (for example `:3.20-2026-09`) are also aliases and must not replace digest pinning in production deployment manifests.

Example:

```dockerfile
FROM ghcr.io/devopsderek/alpine-golden@sha256:<digest>
```

## Signature and verification expectations

- This repository currently does **not** enforce image signing or signature verification in CI.
- If signing is introduced, use repository-supported keyless/OIDC-based signing and add automated verification gates before promotion.
- Until signing is enabled and verified, treat digest pinning + CI checks (tests, Trivy, SBOM/build metadata artifacts) as the enforced controls.

## Vulnerable base image response playbook

When a vulnerable base image or package is identified:

1. Confirm whether a fix is available in upstream base/package repositories.
2. Trigger or run a rebuild for affected image families/versions.
3. Ensure CI passes tests and vulnerability scanning gates.
4. Publish updated images and record resulting immutable digests.
5. Update downstream consumers to the new digests.
6. If no fix exists yet, document the exception (see below), risk acceptance window, and compensating controls.

## Exception process

Any temporary policy exception (for example, a known vulnerability without an available fix) should include:

- Scope (image family/version and affected workloads)
- Justification and risk statement
- Compensating controls
- Time-bound expiration/review date
- Approver (assumption: maintainer/security approver, confirmation required)

Record exceptions in pull request discussions and track follow-up work in issues.

## External prerequisites and maintainer follow-up

- Confirm and document final per-family ownership.
- Confirm cadence assumptions and emergency rebuild SLA.
- If attestation/signing verification is required, enable and document the repository-supported implementation and CI gate.
