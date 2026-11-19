# Ellis Stage 3 — Corridor 17
## B-01 Personal-First Governance Amendment

**Decision date:** 2026-11-19
**Classification:** NONPRODUCTION_GOVERNANCE_ARCHITECTURE_REVISION
**Operating model:** PERSONAL_FIRST_MULTI_ADMINISTRATOR_READY
**Implementation:** NOT_AUTHORIZED
**Operational activation:** WITHHELD

## 1. Purpose

Correct the previously adopted assumption that Ellis requires multiple human administrators during its initial personal-use operation.

The owner has clarified that Ellis is currently intended for operation by one human using personally controlled devices.

Multiple human administrators remain a possible future requirement, not a current operating assumption.

## 2. Personal-First Operating Model

The intended initial operating model is:

- One human owner and accountable administrator.
- Personally controlled MacBook and iPad devices.
- Owner-managed device enrollment, registration, and revocation.
- Session-bounded nonproduction cryptographic verification.
- No mandatory second human administrator solely because the system supports trusted-device registration.

Owner-managed registration must not be represented as independently approved registration.

## 3. Future Multi-Administrator Compatibility

The architecture should preserve the ability to introduce distinct administrative roles, independently authorized registration approvers, separation-of-duties enforcement, and independent acceptance and audit responsibilities.

These requirements become applicable only through a separately reviewed and authorized multi-administrator operating model.

No future organizational authority is established by this amendment.

## 4. Technical Security Invariants

The proposed personal-first model must preserve:

- Explicit owner authorization.
- Verifier-controlled trusted-key storage.
- Cryptographic verification of exact canonical evidence.
- Registration integrity and key-custody protections.
- Session identity, expiration, closure, and revocation enforcement.
- Fail-closed rejection of invalid or ambiguous trust states.
- Acceptance/revocation ordering.
- Bypass-prevention requirements.
- Evidence integrity and custody records.
- Explicit limitations on claims of physical-device origin.

Owner control of both devices must not be misrepresented as independent physical-origin corroboration.

## 5. Governance Reconciliation Required

The existing conditional governance approval remains historically authoritative for the model it approved.

Before personal-first operation can be activated, a separate review must reconcile:

- G1: Independent delegation versus explicit sole-owner authorization.
- G2: Two-human minimum versus one-human personal operation.
- G3: Registration and acceptance role overlap.
- G4: Independent-audit requirements and claims.
- G5: Operational activation criteria.
- A1–A9: Architectural conditions affected by the revised operating model.
- B-01, B-02, and B-03 acceptance contracts.

This amendment records the authorized direction for the revision.

It does not assert that existing independent-approval requirements have already been replaced or satisfied.

## 6. Activation Restrictions

IMPLEMENTATION=NOT_AUTHORIZED

PHYSICAL_DEVICE_TESTING=NOT_AUTHORIZED

KEY_REGISTRATION=NOT_AUTHORIZED

PERSONAL_FIRST_OPERATION=NOT_ACTIVATED

G5_ACTIVATION_GATE=UNSATISFIED

PRODUCTION_ISSUANCE=WITHHELD

DEPLOYMENT=WITHHELD

## 7. Corridor Status

B01=OPEN

B02=OPEN

B03=OPEN

CORRIDOR_17=OPEN

STAGE_3=OPEN

The next permitted activity is bounded architectural and governance reconciliation.

No runtime changes, operational authority activation, or production deployment are authorized by this amendment.
