# ADR 0001: Image promotion identity and signing posture

- Status: Accepted
- Date: 2026-09-26
- Related issue: DevOpsDerek/golden-docker-images#5

## Context

Golden images are built and tested across multiple Linux families. Promotion and deployment guidance needs a single, reliable identity that is resistant to tag drift, while keeping current workflow behavior unchanged.

## Decision

1. Use immutable image digests (`image@sha256:...`) as the promotion/deployment identity.
2. Retain version and CalVer tags as convenience aliases only.
3. Continue current CI security gates (tests + Trivy) and add SBOM/build metadata artifact generation per workflow run.
4. Do not introduce mandatory signing verification in this change because no repository-level verified signing gate exists yet.

## Consequences

- Deployments can pin immutable digests to avoid mutable-tag drift.
- Existing push/tag behavior remains compatible for current consumers.
- Supply-chain evidence improves with SBOM/build metadata artifacts, but signature verification remains a maintainer follow-up.
- A future ADR/update can define signed attestations and verification gates once infrastructure and policy are confirmed.
