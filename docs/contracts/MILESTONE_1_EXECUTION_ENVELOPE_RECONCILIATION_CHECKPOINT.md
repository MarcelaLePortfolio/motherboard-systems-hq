
# Milestone 1 — Execution Envelope Reconciliation Checkpoint

Status: RECONCILIATION REQUIRED

## Purpose

Compare the existing execution-envelope artifacts against the newly frozen Milestone 0 Execution Governance Authority Model.

This checkpoint prevents creation of a second competing execution-envelope architecture.

---

# Existing Artifacts Inspected

## Documentation Contracts

- docs/contracts/CANONICAL_EXECUTION_ENVELOPE_SCHEMA.md

- docs/contracts/CANONICAL_EXECUTION_LIFECYCLE.md

- docs/contracts/DELEGATION_ENVELOPE_V1.md

## Runtime Contract

- server/contracts/execution-envelope.v1.mjs

---

# High-Level Finding

Execution-envelope artifacts already exist.

Milestone 1 is therefore not a greenfield schema creation task.

Milestone 1 must reconcile existing envelope contracts with the Milestone 0 authority model before any schema replacement, runtime patch, validator change, or orchestration work occurs.

---

# Confirmed Existing Strengths

The existing contracts already include several aligned concepts:

- Matilda-to-Cade delegation

- mutation scope boundaries

- forbidden paths

- rollback expectations

- reconciliation requirements

- sandbox / dry-run behavior

- governance validation

- immutable envelope snapshot concept

- fail-closed execution posture

- Cade refusal-style constraints

- audit traceability

These should be preserved where compatible.

---

# Conflict 1 — Delegation As Execution Authorization

## Existing Contract

docs/contracts/DELEGATION_ENVELOPE_V1.md states:

- Delegation itself is the approval event.

- Cade may execute immediately upon receipt of a valid delegation envelope.

- No additional execution confirmation is required after delegation.

## Milestone 0 Conflict

Milestone 0 stabilized:

- User owns Intent Authority.

- Matilda interprets intent but may not create intent.

- Execution must pause when evidence of intent is insufficient.

- Missing intent may not be replaced with inference.

- Runtime separation is not yet fully enforced.

## Required Reconciliation

Delegation may not silently become broad execution authorization.

Delegation can authorize Cade only within explicit, evidence-backed, bounded scope.

If the delegation envelope contains unresolved intent ambiguity, missing rollback conditions, missing validation criteria, or scope uncertainty, Cade must refuse or pause.

---

# Conflict 2 — Envelope Authoritative Over Governed Execution Intent

## Existing Contract

docs/contracts/CANONICAL_EXECUTION_ENVELOPE_SCHEMA.md states:

The envelope is authoritative over governed execution intent.

## Milestone 0 Clarification

Milestone 0 stabilized:

- User owns Intent Authority.

- Matilda owns Interpretation Authority.

- The envelope may preserve established intent.

- The envelope may not create intent.

- The envelope may not replace missing intent with inferred intent.

## Required Reconciliation

The envelope may be authoritative as a preserved interpretation artifact.

The envelope may not be authoritative as an independent source of intent.

Correct framing:

The envelope is authoritative over the bounded delegation contract derived from established user intent.

Incorrect framing:

The envelope is independently authoritative over user intent.

---

# Conflict 3 — Confidence Score In Runtime Implementation

## Existing Runtime Contract

server/contracts/execution-envelope.v1.mjs includes:

- intent.confidence_score

## Milestone 0 Conflict

Milestone 0 stabilized:

- Intent must be supported by evidence.

- Missing intent may not be replaced with inference.

- Intent ambiguity requires user escalation.

## Required Reconciliation

Confidence score must not be used to permit execution when intent evidence is insufficient.

If retained, confidence_score must remain observational only.

It must not function as an execution authorization mechanism.

---

# Conflict 4 — Atlas Missing From Envelope Architecture

## Existing Contracts

Existing envelope contracts primarily model:

- Matilda

- Cade

- governance validation

- reconciliation systems

They do not explicitly model Atlas.

## Milestone 0 Clarification

Milestone 0 stabilized:

Atlas owns:

- Architectural Integrity Authority

- Dependency Analysis Authority

- Impact Analysis Authority

- Roadmap Integrity Authority

## Required Reconciliation

Atlas should not be inserted into the execution authority chain.

However, future envelope revisions may need a field or linked artifact for architectural impact findings when a task affects prior assumptions, dependencies, milestones, or roadmap integrity.

This should remain deferred unless required by the current envelope scope.

---

# Conflict 5 — Effie Missing From Envelope Architecture

## Existing Contracts

Existing envelope contracts do not explicitly model Effie.

## Milestone 0 Clarification

Milestone 0 stabilized:

Effie owns:

- Operational Authority

- Recovery Support Authority

- Backup Authority

## Required Reconciliation

Effie should not be inserted into the execution authority chain.

Future recovery or backup-related envelopes may reference Effie as operational support, but this is deferred from Milestone 1 unless required for rollback or backup integrity.

---

# Conflict 6 — Lifecycle Does Not Explicitly Include Intent Ambiguity Escalation

## Existing Lifecycle

docs/contracts/CANONICAL_EXECUTION_LIFECYCLE.md includes states such as:

- INTENT_CAPTURED

- ENVELOPE_CONSTRUCTED

- VALIDATION_PENDING

- VALIDATED

- DELEGATED

- PLANNING

- PLAN_REVIEW_READY

## Milestone 0 Clarification

Milestone 0 stabilized:

- Deterministic Ambiguity

- Interpretive Ambiguity

- Intent Ambiguity

- Mandatory user escalation for Intent Ambiguity

## Required Reconciliation

Lifecycle should explicitly include ambiguity handling.

At minimum, future lifecycle revisions should include:

- AMBIGUITY_DETECTED

- MATILDA_INTERPRETATION_REVIEW

- USER_ESCALATION_REQUIRED

---

# Conflict 7 — Existing Contracts Do Not Explicitly Preserve Historical Intent

## Existing Contracts

The lifecycle mentions immutable envelope snapshots.

## Milestone 0 Clarification

The emerging Milestone 1 lifecycle requires:

- Frozen envelopes are immutable.

- Completed envelopes are historical records.

- Later user intent changes require a new envelope, not mutation of the old one.

## Required Reconciliation

Future envelope lifecycle contract should explicitly preserve historical intent and prohibit silent envelope rewriting.

---

# Milestone 1 Scope Boundary

Milestone 1 is now narrowed to:

- reconcile existing envelope contracts

- update language that conflicts with Milestone 0

- preserve compatible existing schema structure

- add missing intent-evidence and ambiguity escalation rules

- avoid runtime implementation changes unless explicitly required later

---

# Non-Goals

Not in scope:

- Runtime execution implementation

- State machine implementation

- Runner topology implementation

- Atlas implementation

- Effie implementation

- Full orchestration implementation

- New queue systems

- New approval UI

- New sandbox mechanics

---

# Recommended Next Step

Patch docs/contracts/CANONICAL_EXECUTION_ENVELOPE_SCHEMA.md and docs/contracts/DELEGATION_ENVELOPE_V1.md to align with Milestone 0.

Do not patch server/contracts/execution-envelope.v1.mjs until documentation reconciliation is complete.

