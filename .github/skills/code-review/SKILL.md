---
name: code-review
description: Review pull requests, diffs, or branches in this repository for golden Docker image, GitHub Actions, validation, security, and publishing changes.
---

# Code review for Golden Docker Images

This skill applies to this repository's Alpine, Ubuntu, Debian, and Rocky Linux
golden images. Review the repository as it exists; do not assume it has
Windows images, a CODEOWNERS file, a separate deployment system, or supply-chain
artifacts that are not present.

## 1. Understand intent and context

- Read the linked issue and the PR title and description. State the intended
  outcome in one sentence before reviewing.
- Check that the diff delivers that outcome and does not introduce unrelated
  changes.
- Read relevant Dockerfiles, family and root documentation, build/test scripts,
  and CI workflows around the changed lines. Check all affected image versions
  and family variants, not just the example shown in the PR.

## 2. Verify evidence for the current change

- Check CI results for the current PR head commit. Older runs do not establish
  that the current change passes.
- Distinguish passing checks from skipped, missing, cancelled, or unavailable
  evidence. Do not treat absent evidence as a pass.
- Identify which image-family build, image tests, vulnerability scan, and lint
  checks ran. Report missing validation explicitly; do not claim local or CI
  tests ran without evidence.
- Treat PR checks and release/publish runs separately. A successful build is
  not evidence that an image was safely published or promoted.

## 3. Report actionable findings

- Report only high-confidence issues introduced by, or materially affected by,
  the change. Prefer a few real problems over speculative concerns and style
  nits.
- Anchor each finding to a specific changed file and line. Explain the impact
  and give a concrete remediation.
- Rank correctness, security, and release-blocking findings before
  non-blocking maintainability concerns. Label genuine uncertainty as a
  question rather than a finding.

## 4. Handle sensitive material safely

- If a credential, token, private key, connection string, or sensitive
  infrastructure identifier appears, identify the location without repeating
  its value. Recommend removal and rotation or revocation as appropriate.
- Describe vulnerabilities only to the level needed for remediation. Do not
  put exploit instructions or sensitive details in public review comments;
  direct the author to the repository's private reporting channel when
  disclosure could create risk.

## 5. Require human approval for sensitive changes

Do not approve changes on your own authority. Call out that an authorized human
owner must explicitly review and approve changes to policy, security controls,
credentials handling, image publishing or promotion, or actions that deploy to
or modify real infrastructure. Do not assume a particular owner, branch rule,
or CODEOWNERS requirement without evidence. CI success and automated checks are
not human approval; never automate approval.

## 6. Golden image and CI checks

### Dockerfiles and image behavior

- Verify that each changed image uses the intended upstream distribution and
  release, applies updates with the family-appropriate package manager, and
  keeps labels, installed packages, cleanup, and runtime defaults consistent
  with the family's documentation and tests.
- Check all versions affected by shared scripts, build arguments, or workflow
  changes. Confirm the declared version lists agree with the versions built and
  tested.
- Do not demand digest-pinned Dockerfile bases as a blanket rule. This
  repository uses version-tagged upstream bases and rebuilds with security
  updates; evaluate whether a changed base reference is deliberate and whether
  reproducibility or freshness expectations are documented. For production
  consumers requiring immutable inputs, recommend digest pinning where
  appropriate. Recommend consumers deploy published images by digest when
  immutable identity is needed; do not mistake a mutable release tag for a
  digest.
- Check that secrets are not copied into image layers, passed through
  persistent build arguments, or exposed in build logs. Evaluate non-root
  execution in the context of the image's documented base-image purpose; do
  not require an application-specific user where that would break intended
  base-image behavior.

### Validation and platform coverage

- This repository currently builds Linux images. Verify Linux build, family
  tests, and vulnerability scanning for every affected version using the
  repository's actual scripts and CI. Do not require Windows validation unless
  Windows images or Windows-specific behavior are introduced.
- If Windows images are added, require suitable Windows runners and
  Windows-container build and runtime tests; Linux runner results alone do not
  validate them.
- Treat a Trivy result according to the configured severity and
  `--ignore-unfixed` policy. Do not claim an image is vulnerability-free based
  only on a passing scan.

### Build, publish, and supply chain

- Review workflow/job token permissions for least privilege and justify write
  scopes. Pin third-party actions to full commit SHAs when adding or changing
  action references. Check untrusted input is not interpolated into shell
  commands and secrets are not exposed to fork pull requests or printed.
- Confirm pull requests and non-release branches cannot publish images. Check
  that publishing is gated on the intended default-branch or scheduled event,
  and that tests and scans complete before any push. Verify version and
  CalVer tags are applied to the correct family and image.
- Check that release or promotion changes preserve validated artifacts and
  report the digest of the image actually pushed when the workflow claims
  immutable identity. Do not infer a promotion or registry verification step
  that is not present.
- Claims about an SBOM, provenance, signature, or attestation must be backed
  by a workflow step or artifact that produces it and evidence that it applies
  to the image being released. Do not treat documentation or a successful
  vulnerability scan as proof of those properties.

## 7. Close with a review summary

Summarize the stated intent, checks verified on the current head, missing
evidence, findings by severity, and whether human owner approval is required.
Recommend **approve**, **request changes**, or **comment** and explain why.
