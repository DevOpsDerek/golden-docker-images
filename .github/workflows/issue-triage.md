---
on:
  issues:
    types: [opened, reopened]
permissions:
  contents: read
  issues: read
inlined-imports: true
imports:
  - DevOpsDerek/workflows/.github/workflows/shared/agentic/issue-triage.md@dac4b81c298cb3ea6821ea312efa5375f42d5ccb
tools:
  github:
    toolsets: [issues, labels]
safe-outputs:
  add-comment:
    pull-requests: false
---

Follow the imported issue-triage instructions for the triggering issue. Base
the proposed summary, any recommended label, and any clarification request
only on repository and issue evidence. Use the one safe-output comment only
for that proposed triage; do not change labels, assign, close, or edit issues.
