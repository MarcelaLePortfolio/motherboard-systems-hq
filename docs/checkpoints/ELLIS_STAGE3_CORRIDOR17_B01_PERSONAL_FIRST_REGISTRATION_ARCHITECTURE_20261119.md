# Ellis Stage 3 — Corridor 17 — B-01 Personal-First Registration Architecture

Date: 2026-11-19

Classification: ARCHITECTURE_PROPOSED_NOT_VALIDATED

Scope: Documentation only. Nonproduction architecture planning.

## 1. Authority and Scope

This document records the proposed personal-first trusted-key registration architecture for B-01.

It does not authorize implementation, key registration, physical-device testing, deployment, production issuance, or activation.

The November 19 personal-first governance amendment and reconciliation govern the proposed owner-managed model. Earlier independent-human requirements remain historical and must not be silently rewritten or represented as operationally satisfied.

The single owner may administer the personal-use workflow without a mandatory second human administrator, subject to the documented technical separation and unresolved acceptance conditions.

Owner assessment must be labeled OWNER_ASSESSED, never INDEPENDENTLY_REVIEWED.

## 2. Architectural Boundaries

The proposed architecture preserves:

- Separate iPad signer and MacBook verifier roles.
- Separate candidate-key submission and trusted-key publication.
- Explicit owner authorization for one bounded session.
- Verifier-controlled trust publication and resolution.
- Exact canonical manifest verification.
- Explicit confirmation before each signing operation.
- No evidence-derived key self-enrollment.
- No private-key export into registration evidence.
- Session expiration, closure, and revocation enforcement.
- Fail-closed treatment of missing, ambiguous, stale, or conflicting trust.
- Separate cryptographic verification and physical-origin conclusions.
- No production issuance or simulated-to-physical promotion.

Owner authorization does not automatically establish independent device provenance or satisfy final acceptance requirements.

## 3. Existing Technical Evidence

The iPad Swift feasibility and approval-gate prototypes currently generate an ephemeral Ed25519 signing key during the confirmed signing operation.

The exported iPad public key uses the raw Ed25519 representation.

The isolated Node verifier resolves a trusted iPad key through a verifier-controlled dependency and expects an Ed25519 SubjectPublicKeyInfo DER representation.

The verifier checks the SHA-256 fingerprint of the exact SPKI DER bytes and validates the signature against the canonical manifest.

Existing tests establish selected signing and rejection behavior, not a completed owner-authorized registration lifecycle.

The repository contains SQLite transactional governance lifecycle patterns and ordered execution reconciliation patterns. Those mechanisms do not establish an existing B-01 trusted-key registry.

No existing governance table is approved for repurposing by this document.

## 4. Proposed Registration Lifecycle

The following states and transitions are proposed, not implemented.

1. CANDIDATE: The iPad generates a session-bounded Ed25519 signing key before manifest signing.
2. PENDING_OWNER_AUTHORIZATION: The MacBook receives the candidate public-key record as untrusted evidence.
3. OWNER_AUTHORIZED: The owner explicitly authorizes the exact candidate key, role, and bounded session.
4. APPROVED_NONPRODUCTION: The verifier-controlled registry atomically publishes the authorized trust record after rechecking the session and registration state.
5. REJECTED: The registration is denied and cannot become trusted.
6. REVOKED: Previously published trust is withdrawn.
7. EXPIRED: The registration or session exceeds its permitted lifetime.
8. CLOSED: The bounded session terminates.

Only APPROVED_NONPRODUCTION, with an active matching session and current authoritative trust state, may be considered eligible for verification.

REJECTED, REVOKED, EXPIRED, and CLOSED are terminal for the affected registration.

Replacement keys and new sessions require new registration records.

## 5. Candidate Registration Contract

The proposed candidate record contains:

- Unique candidate registration identifier.
- Exact bounded session identifier.
- Explicit IPAD_SIGNER_NONPRODUCTION role.
- Ed25519 public-key bytes in an approved canonical encoding.
- SHA-256 fingerprint of the exact encoded public-key bytes.
- Candidate creation and validity information.
- Source and destination references.
- Transfer-integrity evidence.
- Custody and correlation references.
- Explicit nonproduction classification.

SPKI DER is the proposed canonical public-key representation because the existing Node verifier requires it.

Swift raw-key to SPKI DER conversion must be explicit, specified, and independently validated before registration is executable.

The fingerprint is a byte-level identifier, not proof of physical-device origin.

## 6. Owner Authorization and Trust Publication

Candidate receipt does not establish trust.

Owner authorization must identify the exact candidate registration, key fingerprint, role, and bounded session.

The MacBook verifier must control trusted-key publication independently of the submitted signing evidence.

Publication must recheck authorization, registration state, session state, expiration, and revocation within an authoritative transaction.

The signer must not approve or publish its own trusted-key record.

The same human owner may perform permitted administrative actions in the personal-first model, but the technical authority boundaries remain separate.

No owner authorization may be interpreted as independent physical-origin corroboration.

## 7. Persistence and Event Ordering

The proposed persistence boundary is a dedicated nonproduction SQLite trusted-key registry, separate from existing governance lifecycle and execution reconciliation tables.

The design should follow established transactional patterns without changing unrelated governance contracts.

Each registration event must have a unique identifier, exact session association, and database-assigned monotonic ordering.

Trust publication must be atomic with validation of the latest authoritative registration and session state.

Delayed approval cannot override revocation, expiration, rejection, or session closure.

Unknown, conflicting, or stale event ordering must fail closed.

The authoritative event schema, transaction semantics, concurrency rules, and recovery behavior remain subject to specification and validation.

## 8. Signing and Verification

The iPad must retain the private signing key for the authorized bounded session without exporting it into registration evidence.

The proposed pre-signing key-generation step must not weaken the existing explicit confirmation requirement.

Signing remains conditional on exact manifest verification, applicable approval evidence, and separate user confirmation.

The MacBook verifier must resolve the trusted key from its authoritative registry rather than from the submitted signature envelope.

Verification must reject absent, mismatched, revoked, expired, closed, ambiguous, or session-incompatible trust records.

Cryptographic success must not be represented as independent physical-device attestation.

## 9. Transfer, Custody, and Device Association

Candidate-key transfer must use a separately approved integrity-verifiable nonproduction method.

Candidate transfer must not automatically populate the trusted-key registry.

The workflow must preserve exact bytes, fingerprint, session, role, source, destination, transfer integrity, and custody references.

Personal-first device association may be OWNER_ASSESSED when supported by an explicitly defined owner observation procedure.

Owner observation does not establish hardware-backed private-key custody, secure attestation, or independent physical-origin corroboration.

Any acceptance requirement demanding independent corroboration remains blocked until independently satisfied or formally reconsidered through governance.

## 10. Revocation and Closure

Revocation and session closure must prevent subsequent trusted verification for the affected registration.

The verifier must consult authoritative current state.

Uncertain or unavailable revocation state must fail closed.

A delayed authorization or publication event must not restore a terminal registration.

Offline revocation distribution, stale-state policy, authoritative ordering, and recovery behavior remain open design decisions.

## 11. Required Validation Before Implementation Approval

The following conditions remain unresolved:

1. Exact Swift raw Ed25519 to canonical SPKI DER compatibility.
2. Session-bounded private-key lifetime and custody.
3. Candidate transfer mechanism and custody integrity.
4. Explicit owner authorization record and evidence requirements.
5. Verifier-controlled publication and bypass prevention.
6. Atomic event ordering, revocation, expiration, and closure.
7. Owner-assessed device-association procedure and claim limitations.
8. Negative tests for missing, stale, revoked, conflicting, or mismatched trust.
9. Reconciliation of historical independent-human conditions with the personal-first governance model.
10. Formal nonproduction acceptance criteria and required corroboration boundaries.

These conditions must be addressed through separately authorized design, implementation, and validation stages.

## 12. Current Project State

Baseline branch: feature/support-source-references-runtime

Baseline commit: 91cce430e

DR checkpoint: VERIFIED

Checklist: 9_OF_12

B-01 architecture: PROPOSED_NOT_VALIDATED

B-02: OPEN

B-03: OPEN

Physical device provenance: PHYSICAL_DEVICE_UNCORROBORATED

G5 activation gate: UNSATISFIED

Corridor 17: OPEN

Stage 3: OPEN

Implementation: NOT_AUTHORIZED

Key registration: NOT_AUTHORIZED

Physical-device testing: NOT_AUTHORIZED

Deployment: NOT_AUTHORIZED

Production issuance: NOT_AUTHORIZED

## 13. Documentation Boundary

This record is a proposed architecture checkpoint only.

It does not constitute operational approval, implementation completion, registration approval, independent review, device provenance corroboration, or corridor closure.

All subsequent work requires explicit authorization appropriate to its scope.
