PHASE 423.3 — SNAPSHOT HELPER PLAN

Next implementation target:

Create one stable exported governance eligibility helper.

Required output shape:

{
  authorizationEligible: boolean,
  governanceReason: string | null
}

Rules:

- Build full governance chain inside governance layer
- Export only final eligibility snapshot
- Entrypoint must consume helper only
- No coupling to governance internals from execution layer
