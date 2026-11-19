# Ellis Stage 3 — Corridor 17
## Personal-First Governance Reconciliation

Date: 2026-11-19
Classification: NONPRODUCTION_ARCHITECTURE_RECONCILIATION
Baseline: 31e459b6b
Status: RECONCILIATION_RECORDED_NOT_OPERATIONALLY_APPROVED

## 1. Governing Decision

Ellis currently has one human owner and administrator.

The intended personal-use architecture permits owner-managed device registration and revocation without requiring a second human administrator.

Future multi-administrator operation requires separate governance review and authorization.

This decision does not activate any operational authority.

## 2. G1–G5 Reconciliation

### G1 — Registration Authority

Replace the proposed independent-human delegation requirement for personal operation with explicit, bounded sole-owner authorization.

Existing credential-administration authority must not silently confer registration authority.

### G2 — Participant Model

Personal mode requires one accountable human owner.

The MacBook verifier and iPad signer remain distinct technical roles.

A second human is not mandatory in personal mode.

### G3 — Registration and Acceptance

The owner may perform registration administration and personal evidence assessment.

Such assessments must be labeled OWNER_ASSESSED rather than INDEPENDENTLY_REVIEWED.

No assessment may claim independence that does not exist.

### G4 — Independent Audit

Independent-human audit requirements remain applicable whenever an independent audit is explicitly required.

Personal operation must not misrepresent owner review as independent audit.

Any positive physical-origin or final-acceptance classification that requires independent corroboration remains blocked until its evidence standard is separately reconciled and satisfied.

### G5 — Activation Gate

Retain mandatory activation controls for:

- Explicit owner authorization.
- Verifier-controlled trust publication.
- Signing-key custody and registration integrity.
- Session binding, expiration, closure, and revocation.
- Cryptographic-result and evidence binding.
- Acceptance/revocation ordering.
- Bypass prevention.
- Ephemeral-key feasibility.
- Approved physical-origin evidence standards.
- Approved final-acceptance procedures.

The personal-first amendment does not satisfy G5.

## 3. A1–A9 Reconciliation

A1: Replace organizational independent-human delegation with explicit bounded owner authority for personal mode.

A2: Preserve registration integrity, custody, and verifier-controlled trust publication.

A3: Preserve session lifecycle, expiration, closure, and revocation enforcement.

A4: Preserve authoritative acceptance/revocation ordering.

A5: Preserve trusted cryptographic-result and evidence binding.

A6: Preserve bypass prevention and fail-closed behavior.

A7: Preserve ephemeral-key feasibility validation.

A8: Preserve physical-device association requirements; owner observation cannot be labeled independent corroboration.

A9: Preserve evidence acceptance governance; owner assessment and independent acceptance must remain distinguishable.

All A1–A9 conditions remain OPEN pending validation.

## 4. B-01 Registration Reconciliation

Personal-mode registration may be owner-authorized but must not be evidence-derived or automatically self-enrolled.

Candidate-key submission and trusted-key publication remain distinct operations.

The verifier must reject unapproved, expired, revoked, ambiguous, or session-mismatched keys.

Exact encoding, transport, revocation distribution, and ephemeral-key feasibility remain unresolved.

## 5. B-02 Physical-Origin Reconciliation

Cryptographic verification does not prove physical origin.

Owner observation may be recorded as owner-supplied evidence but cannot establish independent corroboration.

The physical-origin evidence standard requires separate approval before physical testing.

Existing PHYSICAL_DEVICE_UNCORROBORATED classification remains unchanged.

## 6. B-03 Acceptance Reconciliation

Personal-mode owner assessment and independently reviewed acceptance are different classifications.

No existing mandatory acceptance criterion is silently waived.

A future acceptance procedure must explicitly define which outcomes are permissible without an independent human reviewer.

Until then, existing positive acceptance gates remain unsatisfied.

## 7. Documentation and DR

This record documents architectural reconciliation only.

A nondestructive DR checkpoint is required before any subsequent implementation or security-sensitive operational change.

Existing unrelated working-tree modifications and untracked files must remain untouched.

## 8. Current Status

CHECKLIST=9_OF_12

DEVICE_CONNECTION=NOT_REQUIRED

DOCUMENTATION=RECONCILIATION_RECORDED

DR=REQUIRED_BEFORE_IMPLEMENTATION

IMPLEMENTATION=NOT_AUTHORIZED

PHYSICAL_DEVICE_TESTING=NOT_AUTHORIZED

KEY_REGISTRATION=NOT_AUTHORIZED

G5_ACTIVATION_GATE=UNSATISFIED

B01=OPEN

B02=OPEN

B03=OPEN

CORRIDOR_17=OPEN

STAGE_3=OPEN
