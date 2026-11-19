# Ellis Stage 3 — Corridor 17 — B-01 Milestone 11 Registration Specification

Date: 2026-11-19
Classification: PROPOSED_NONPRODUCTION_SPECIFICATION_NOT_VALIDATED
Scope: Documentation only
Authorization: B-01 milestone 11 specification documentation only
Implementation authorization: NOT GRANTED
Operational activation: NOT AUTHORIZED

## 1. Purpose

Specify how a session-bounded iPad Ed25519 signing key may become trusted by the MacBook Ellis verifier without introducing a third owner authorization.

This document refines the proposed personal-first B-01 architecture. It does not implement, approve, or validate trusted-key registration.

The existing two-authorization workflow remains a design requirement.

## 2. Verified Baseline

The inspected nonproduction iPad prototype:

- Verifies a canonical manifest and simulated iPhone P-256 approval evidence.
- Presents the reviewed manifest, its SHA-256 digest, and its exact UTF-8 bytes.
- Requires explicit confirmation before signing.
- Consumes the reviewed request before attempting signing.
- Generates an ephemeral Ed25519 private key after confirmation.
- Returns the raw Ed25519 public key and signature as verification evidence.
- Does not implement trusted-key registration or physical-device provenance.

The review sheet's dismissal callback currently clears reviewedManifest but does not clear pendingApproval.

The existing signing guard requires both a reviewed manifest and matching pending approval, so this observation does not by itself establish a signing bypass.

The existing Ellis Node verifier resolves a trusted iPad public key through verifier-controlled dependencies. Successful cryptographic verification does not establish trusted registration, private-key custody, or physical-device origin.

## 3. Authorization Invariant

Preserve exactly two owner authorization interactions:

1. First authorization: approval of the exact proposed action.
2. Second authorization: explicit confirmation of the exact action and the identified candidate iPad signing key for the bounded session.

The second interaction may carry both signing confirmation and candidate-registration authorization only when its displayed content and authoritative evidence explicitly bind both purposes.

No third owner confirmation is proposed.

A signing confirmation that lacks the required candidate-registration binding must not be interpreted as registration authorization.

The iPad signer must not independently approve or publish its own trusted-key record.

## 4. Proposed Candidate Preparation

Before presenting the existing second confirmation:

1. Verify the applicable first-authorization evidence and canonical manifest.
2. Generate a new ephemeral Ed25519 signing key for the bounded session.
3. Retain the private key exclusively within the iPad signing controller.
4. Convert the raw 32-byte Ed25519 public key into canonical SPKI DER.
5. Calculate SHA-256 over the exact SPKI DER bytes.
6. Construct an untrusted candidate record.
7. Associate the candidate with the exact reviewed manifest and pending confirmation.

The canonical Ed25519 SPKI DER representation consists of the DER prefix:

302a300506032b6570032100

followed by the 32-byte raw Ed25519 public key.

The resulting representation is 44 bytes. This compatibility rule has synthetic feasibility evidence but still requires acceptance validation within the registration lifecycle.

Candidate preparation must not sign the manifest, publish trust, or constitute owner authorization.

## 5. Candidate Record

The proposed candidate record must bind:

- Unique candidate registration identifier.
- Exact bounded session identifier.
- Explicit IPAD_SIGNER_NONPRODUCTION role.
- Canonical Ed25519 SPKI DER public-key bytes.
- SHA-256 fingerprint of those exact bytes.
- Exact canonical manifest SHA-256.
- Candidate creation time and bounded expiration.
- Source, destination, transfer-integrity, and custody references.
- Explicit nonproduction classification.

Candidate receipt is untrusted evidence, not a trusted-key registration.

No private-key bytes may appear in candidate records, authorization evidence, logs, or exported verification envelopes.

## 6. Existing Second Confirmation

The existing manifest review and confirmation interaction must be extended, not replaced.

Before the owner confirms, the interface must present or unambiguously identify:

- The exact action and reviewed manifest.
- The canonical manifest fingerprint.
- The candidate registration identifier.
- The candidate public-key SPKI fingerprint.
- The bounded session identifier.
- The nonproduction iPad signer role.
- The explicit purpose of authorizing this candidate key for that session.

The confirmation evidence must bind these values to one single-use decision.

The displayed candidate and the candidate subsequently submitted for registration must be byte-identical.

The signing controller must revalidate the exact manifest, applicable first-authorization evidence, candidate identity, session state, and second-confirmation binding before signing.

A generic explicitlyConfirmed boolean is not sufficient evidence of registration authorization.

## 7. Cancellation, Dismissal, and Failure

The signing controller must maintain one authoritative pending candidate for the reviewed request.

Cancellation, review-sheet dismissal, manifest replacement, mismatched approval evidence, invalid confirmation, expired session, registration rejection, or signing failure must:

- Clear the reviewed manifest and pending approval.
- Invalidate the pending candidate and its registration authority.
- Release the controller's private-key reference.
- Prevent later publication of trust for that invalidated candidate.
- Require a fresh candidate and fresh applicable confirmation before retry.

Successful completion must consume the confirmation and close the pending signing request.

If the session remains valid for later permitted operations, any key reuse must follow a separately specified session-lifetime policy and must not reuse a consumed signing confirmation.

Revoked, rejected, expired, and closed registrations must not be resurrected by delayed events.

## 8. Ellis-Controlled Trust Publication

The MacBook Ellis verifier must maintain a dedicated authoritative nonproduction trusted-key registry.

Candidate transfer must never populate trusted-key state automatically.

Before publishing trust, Ellis must independently validate:

- The exact candidate and canonical public-key bytes.
- The candidate's session, role, and expiration.
- The authoritative owner-authorization evidence.
- The exact second-confirmation binding.
- The current registration and session state.
- The absence of rejection, revocation, closure, replay, or conflicting registration.

Authorization validation and trusted-key publication must occur within an authoritative atomic transaction.

The publication transaction must assign authoritative event ordering and preserve auditable evidence.

Any stale, ambiguous, conflicting, or unavailable authoritative state must fail closed.

Only approved, currently valid, session-compatible nonproduction keys may be returned by the verifier-controlled trusted-key resolver.

The submitted signature envelope must never supply its own trust authority.

## 9. Signing and Verification

The iPad signs only the exact canonical manifest after applicable approval verification and the existing explicit signing confirmation.

The private signing key remains under iPad controller custody and is not exported.

Ellis must resolve the corresponding trusted key independently and verify:

- Exact canonical manifest bytes.
- Exact manifest digest.
- Approved trusted-key identity and SPKI fingerprint.
- Valid Ed25519 signature.
- Applicable bounded session and nonproduction classification.
- Current registration, expiration, revocation, and closure state.

Cryptographic success must not be represented as proof of physical-device identity or independent provenance.

Production credential issuance remains prohibited.

## 10. Required Negative Tests

Implementation acceptance must include rejection of:

- Missing or unbound registration authorization.
- A candidate key generated after the confirming decision.
- Candidate or fingerprint substitution.
- Manifest or session substitution.
- Unconfirmed signing.
- Cancelled or dismissed review.
- Replayed or consumed confirmation.
- Expired or revoked registration.
- Closed session or stale authorization.
- Conflicting concurrent publication.
- Audit-write failure during publication.
- Missing or unavailable authoritative registry state.
- Wrong public key, signature, or SPKI encoding.
- Production-issuance claims.
- Attempts to treat owner assessment as independent physical provenance.

Recovery, crash consistency, and delayed-event ordering must also be validated before operational acceptance.

## 11. Open Design and Acceptance Conditions

This document does not resolve:

- Final authoritative registration and audit-event schemas.
- Private-key lifetime, in-memory custody, and zeroization behavior.
- Candidate transport and integrity-verification mechanism.
- Exact second-confirmation evidence format and its independent verification.
- Concurrency, recovery, revocation distribution, and stale-state rules.
- Physical iPad association and independent corroboration.
- Final B-02 and B-03 acceptance requirements.
- Governance reconciliation and G5 activation approval.

These conditions remain open until independently specified, implemented where authorized, and validated.

## 12. Milestone and Corridor Status

B-01 checklist: 9 OF 12

Milestone 10: OPEN
Milestone 11: SPECIFICATION DOCUMENTED; IMPLEMENTATION AND VALIDATION OPEN
Milestone 12: OPEN

B-02: OPEN
B-03: OPEN
G5 activation gate: UNSATISFIED
Corridor 17: OPEN

This document is not an operational approval, trusted-key registration, physical provenance finding, independent review, or corridor closure.

Further implementation, physical testing, registration, activation, and deployment require separate explicit authorization.
