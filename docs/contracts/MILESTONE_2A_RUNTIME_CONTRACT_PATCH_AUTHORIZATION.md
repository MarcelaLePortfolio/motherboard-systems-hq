
# Milestone 2A — Runtime Contract Patch Authorization

Status: AUTHORIZED

## Purpose

Authorize a narrow runtime contract patch after Milestone 2 runtime contract review.

This authorization does not permit runtime execution implementation.

---

## Authority Source

- MILESTONE_0_EXECUTION_GOVERNANCE_AUTHORITY_MODEL.md

- MILESTONE_1C_CLOSEOUT.md

- MILESTONE_2_RUNTIME_CONTRACT_REVIEW_SCOPE.md

- MILESTONE_2_RUNTIME_CONTRACT_REVIEW.md

---

## Target File

Authorized runtime contract target:

- server/contracts/execution-envelope.v1.mjs

---

## Authorized Amendments

Only the following amendments are authorized:

1. Add intent_evidence to intent.

2. Preserve confidence_score only as non-authoritative metadata.

3. Add governance authority fields:

   - intent_authority = user

   - interpreter = matilda

   - executor = cade

   - intent_creation_prohibited = true

   - inference_may_replace_missing_intent = false

4. Add ambiguity policy fields:

   - deterministic_ambiguity = matilda_may_resolve

   - interpretive_ambiguity = matilda_may_resolve_with_user_visibility

   - intent_ambiguity = escalate_to_user

5. Add Cade execution constraints:

   - must_not_create_intent

   - must_not_infer_missing_intent

   - must_pause_when_intent_evidence_insufficient

---

## Explicitly Forbidden

This authorization does not permit:

- execution engine implementation

- orchestration implementation

- state machine implementation

- API route changes

- database changes

- shell execution behavior changes

- runner topology changes

- Atlas implementation

- Effie implementation

- autonomous execution behavior

- mutation behavior changes

---

## Validation Required

After the runtime contract patch:

- grep must confirm intent_evidence exists

- grep must confirm confidence_score is marked non-authoritative

- grep must confirm intent_authority exists

- grep must confirm intent_creation_prohibited exists

- grep must confirm inference_may_replace_missing_intent exists

- grep must confirm intent_ambiguity exists

- grep must confirm Cade missing-intent constraint exists

---

## Exit Criteria

Milestone 2A completes when the runtime contract patch is applied, verified, committed, and pushed.

