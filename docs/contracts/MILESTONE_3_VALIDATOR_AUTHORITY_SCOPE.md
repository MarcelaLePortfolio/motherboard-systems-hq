
# Milestone 3 — Validator Authority Scope

Status: SCOPE DEFINED

## Purpose

Define validator authority before any validator implementation, validator runtime patch, validation route, or enforcement behavior is modified.

Milestone 3 exists to prevent validators from silently becoming interpreters, authors, executors, or hidden governance authorities.

---

## Authority Boundary

Validators possess:

- veto authority

- escalation authority

- audit authority

Validators do not possess:

- intent authority

- interpretation authority

- authorship authority

- execution authority

---

## Core Principle

Validators may verify.

Validators may block.

Validators may escalate.

Validators may record findings.

Validators may not create, modify, infer, or expand user intent.

---

## Validator MAY

- validate schema completeness

- validate scope completeness

- validate rollback completeness

- validate reconciliation completeness

- validate intent evidence presence

- validate governance authority fields

- validate ambiguity policy presence

- reject invalid envelopes

- block delegation to Cade

- request escalation

- produce validation findings

- produce validation traces

- produce validation summaries

---

## Validator MAY NOT

- create intent

- modify user intent

- modify envelope intent

- invent intent evidence

- infer missing intent

- resolve intent ambiguity

- expand mutation scope

- expand execution authority

- reclassify user objectives

- override governance constraints

- override Matilda interpretation

- override user authority

- execute work

- instruct Cade to bypass validation

---

## Fail-Closed Rule

Validation fails if any of the following are true:

- intent evidence is missing

- intent evidence is insufficient

- governance authority fields are missing

- ambiguity policy is missing

- rollback contract is missing

- reconciliation contract is missing

- mutation scope is incomplete

- forbidden scope conflict exists

- intent ambiguity is present

- envelope implies inference may replace missing intent

When validation fails:

- delegation is blocked

- Cade receives no executable authorization

- finding is recorded

- escalation route is determined

---

## Failure Categories

### Class A — Structural Failure

Examples:

- schema invalid

- required field missing

- malformed envelope

- invalid scope definition

Result:

- validation fails

- delegation blocked

- Cade does not receive executable authorization

---

### Class B — Governance Failure

Examples:

- missing rollback contract

- missing reconciliation contract

- forbidden scope conflict

- authority field violation

Result:

- validation fails

- delegation blocked

- governance finding recorded

---

### Class C — Intent Evidence Failure

Examples:

- no intent evidence

- evidence insufficient

- evidence contradicts objective

Result:

- validation fails

- user clarification required

- validator may not repair envelope

---

### Class D — Ambiguity Failure

Examples:

- multiple valid interpretations

- unclear objective

- unclear mutation target

- unclear project target

Result:

- validation fails or pauses

- ambiguity is classified

- validator may not choose an interpretation

---

## Escalation Routing

### Intent Problems

Route:

Validator

→ Matilda

→ User

Examples:

- insufficient intent evidence

- conflicting objectives

- ambiguous intent

- unclear authorization

---

### Execution Contract Problems

Route:

Validator

→ Matilda

Examples:

- forbidden scope conflict

- rollback missing

- reconciliation missing

- validation requirements missing

---

## Validator Non-Authorship Principle

Validator findings are descriptive, not corrective.

Validator may say:

- intent evidence missing

- envelope invalid

- ambiguity exists

Validator may not say:

- user intended X

- envelope should be rewritten as Y

- ambiguity is resolved as interpretation B

---

## Validator Output Requirements

Validator output must include:

- envelope id

- validation result

- findings

- severity

- category

- recommended escalation path

- timestamp

- checks performed

- checks passed

- checks failed

---

## Validator Independence Rule

Validator validates the envelope contract.

Validator does not validate Cade execution plans unless a later milestone explicitly scopes that authority.

Reconciliation validates execution outcomes.

Validation and reconciliation remain separate responsibilities.

---

## Out of Scope

Not authorized in Milestone 3 scope definition:

- validator implementation

- runtime validator patch

- API route changes

- database changes

- execution engine changes

- orchestration changes

- state machine implementation

- runner topology changes

- Atlas implementation

- Effie implementation

---

## Exit Criteria

Milestone 3 scope is complete when validator authority, validator non-authority, failure categories, escalation routing, and output requirements are documented.

Next eligible work:

- validator governance review

- not validator implementation

