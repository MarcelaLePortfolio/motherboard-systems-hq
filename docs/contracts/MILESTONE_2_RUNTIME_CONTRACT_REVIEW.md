
# Milestone 2 — Runtime Contract Review

Status: REVIEW COMPLETE

## Purpose

Review server/contracts/execution-envelope.v1.mjs against the Milestone 0 authority model and Milestone 1C canonical documentation reconciliation.

This review does not authorize runtime modification by itself.

---

## Runtime Artifact Reviewed

- server/contracts/execution-envelope.v1.mjs

---

## Aligned Runtime Fields

The runtime contract already includes:

- identity.origin = matilda

- identity.target = cade

- project_target

- mutation_scope.allowed_paths

- mutation_scope.forbidden_paths

- validation_contract

- rollback_contract

- reconciliation

- sandbox.dry_run_required

- sandbox.allow_external_side_effects

- delegation_authorization

- cade_execution_constraints.must_be_bounded

- cade_execution_constraints.must_not_expand_scope

- cade_execution_constraints.must_not_override_mutation_scope

- cade_execution_constraints.must_stop_on_validation_failure

These fields are broadly aligned with the canonical documentation contracts.

---

## Gap 001 — Missing Intent Evidence Field

Current runtime intent structure includes:

- raw_user_intent

- normalized_intent

- intent_type

- confidence_score

Missing:

- intent_evidence

Milestone 0 requires:

- intent must be supported by evidence

- missing intent may not be replaced with inference

- insufficient intent evidence requires escalation

Decision:

AMEND REQUIRED BEFORE RUNTIME AUTHORITY EXPANDS

---

## Gap 002 — confidence_score Governance Risk

Current runtime contract includes:

- confidence_score

Risk:

Confidence may be mistaken for authorization.

Milestone 0 requires:

- confidence is not equivalent to intent evidence

- missing intent may not be replaced with inference

- intent ambiguity requires user escalation

Decision:

AMEND REQUIRED BEFORE RUNTIME AUTHORITY EXPANDS

Required clarification:

confidence_score may remain only as non-authoritative metadata.

confidence_score must not authorize execution.

---

## Gap 003 — Missing Intent Creation Prohibition

Current runtime contract does not explicitly encode:

- intent_creation_prohibited

- inference_may_replace_missing_intent

Milestone 1C documentation now requires both.

Decision:

AMEND REQUIRED BEFORE RUNTIME AUTHORITY EXPANDS

---

## Gap 004 — Missing Ambiguity Policy

Current runtime contract does not explicitly encode:

- deterministic ambiguity handling

- interpretive ambiguity handling

- intent ambiguity escalation

Milestone 1C lifecycle now requires ambiguity routing.

Decision:

AMEND REQUIRED BEFORE RUNTIME AUTHORITY EXPANDS

---

## Gap 005 — Missing User Intent Authority Field

Current runtime contract encodes:

- origin = matilda

- target = cade

But does not explicitly encode:

- intent_authority = user

Milestone 0 requires:

- user remains sole intent authority

Decision:

AMEND REQUIRED BEFORE RUNTIME AUTHORITY EXPANDS

---

## Forbidden During This Review

This review does not authorize:

- runtime execution implementation

- orchestration implementation

- state machine implementation

- execution engine implementation

- runner topology changes

- Atlas implementation

- Effie implementation

- API route changes

- database changes

---

## Amendment Eligibility

A future runtime contract patch may be authorized only if it remains limited to:

- adding intent_evidence

- marking confidence_score as non-authoritative

- adding governance authority fields

- adding ambiguity policy fields

- adding Cade refusal constraints related to missing intent evidence

No execution behavior changes are authorized by this review.

---

## Review Result

Runtime contract review complete.

Runtime contract amendment is eligible for a future narrowly scoped documentation-aligned patch.

