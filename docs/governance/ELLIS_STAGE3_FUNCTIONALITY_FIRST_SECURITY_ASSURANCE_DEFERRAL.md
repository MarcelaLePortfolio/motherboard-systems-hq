# Ellis Stage 3 — Functionality-First Security Assurance Deferral

Decision date: 2026-11-16
Decision: APPROVED
Classification: Work sequencing only

## Decision

Complete and validate Ellis Stage 3 nonproduction functionality
before returning to outstanding security assurance.

Security requirements are deferred, not waived.

Existing security controls and governance boundaries remain intact.

## Approved Sequence

1. Complete remaining Stage 3 functionality.
2. Validate functionality using isolated, nonproduction conditions.
3. Resume deferred security assurance.
4. Establish production readiness through separate authorization.

Functional validation does not establish production security
readiness or independently close Stage 3.

Implementation and testing still require their existing
authorizations.

## Deferred Work Registry

DEFERRED_WORK_ID=ELLIS_STAGE3_IPHONE_V4_V6
FUNCTIONALITY_FIRST=APPROVED
SECURITY_ASSURANCE=DEFERRED_NOT_WAIVED
V4=BIOMETRIC_LOCKOUT_UNTESTED
V6=ENROLLMENT_INVALIDATION_UNTESTED
DEVICE_RECOVERY_SAFEGUARDS=NOT_ESTABLISHED
V6_PERSISTENT_NONPRODUCTION_KEY=NOT_IMPLEMENTED
STATUS=OPEN_DEFERRED

RESUME_AFTER=NONPRODUCTION_FUNCTIONAL_VALIDATION
RESUME_BEFORE=PRODUCTION_CREDENTIAL_ISSUANCE_AUTHORIZATION

## Additional Outstanding Security Requirements

The sequencing decision also preserves requirements for:

- Independent human administrative authority provenance.
- Independent trust-source establishment and verification.
- Protected signing-key custody and recovery.
- Trusted verification-key registration and revocation.
- Replay prevention and single-use authorization enforcement.
- Protected audit and credential lifecycle controls.
- Applicable negative security tests and governance acceptance.

This list does not replace existing security acceptance records.

## Security Boundaries

The selected private-use architecture remains unchanged:

- MacBook: Motherboard host and enforcement runtime.
- iPhone: Independent human approval.
- iPad: Separate Ed25519 manifest signing.

No agent may originate or approve its own authority.

No existing security enforcement may be bypassed to enable
functional testing.

Functional tests must not issue production credentials or
exercise unapproved production authority.

Any test requiring an unverified security property must remain
isolated or wait for the relevant security validation.

Physical biometric-lockout testing, Face ID enrollment changes,
persistent test-key creation, and device recovery operations
require separate explicit authorization.

## Reopening Conditions

Reopen the deferred security-assurance work after the relevant
nonproduction functionality has been validated.

Reopen earlier if a proposed test or implementation would depend
on an unverified security property or create material device risk.

All applicable security requirements must be satisfied before
production credential issuance is authorized.

## Discoverability

Search terms:

ELLIS_STAGE3_FUNCTIONALITY_FIRST_SECURITY_ASSURANCE_DEFERRAL
ELLIS_STAGE3_IPHONE_V4_V6
FUNCTIONALITY_FIRST
SECURITY_ASSURANCE
RESUME_BEFORE
PRODUCTION_CREDENTIAL_ISSUANCE_AUTHORIZATION

Related records:

- docs/checkpoints/ELLIS_ISOLATED_VALIDATION_CHECKPOINT_20261111.md
- docs/governance/ELLIS_STAGE3_PRIVATE_USE_DEVICE_SECURITY_DECISION_20261026.md
- docs/governance/ELLIS_STAGE3_DEFERRED_INDEPENDENT_TRUST_SOURCE.md
- prototypes/ellis-stage3-iphone-feasibility/PHYSICAL_IPHONE_VALIDATION_EVIDENCE.md
- prototypes/ellis-stage3-iphone-feasibility/PHYSICAL_IPHONE_VALIDATION_PLAN.md

## Final Classification

FUNCTIONALITY_FIRST=APPROVED
SECURITY_ASSURANCE_DEFERRED=YES
SECURITY_ASSURANCE_WAIVED=NO
PRODUCTION_CREDENTIAL_ISSUANCE=BLOCKED
STAGE_3=OPEN
STAGE_3_CLOSURE=WITHHELD
STAGE_4_AUTHORIZED=NO
