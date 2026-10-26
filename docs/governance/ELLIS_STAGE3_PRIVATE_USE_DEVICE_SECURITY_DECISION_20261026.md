# Ellis Stage 3 — Private-Use Device Security Architecture Decision

Decision date: 2026-10-26

## Decision classification

ARCHITECTURE_SELECTED=YES
SCOPE=PRIVATE_INTERNAL_USE
DESIGN_DOCUMENTATION_AUTHORIZED=YES
IMPLEMENTATION_AUTHORIZED=NO
TEST_EXECUTION_AUTHORIZED=NO
KEY_PROVISIONING_AUTHORIZED=NO
DEPLOYMENT_AUTHORIZED=NO
PRODUCTION_READINESS=NOT_ESTABLISHED
STAGE_3=OPEN
STAGE_3_CLOSURE=WITHHELD
STAGE_4_AUTHORIZED=NO
COMMIT_AUTHORIZED=NO
PUSH_AUTHORIZED=NO

## Purpose

Record the selected private-use security architecture for Ellis
Corridor 4 Stage 3 and preserve it as a discoverable decision for
future repository investigations and corridor planning.

This decision selects an architecture. It does not establish
working device applications, verified security properties,
production trust, or authorization to implement.

## Selected architecture

### Motherboard host — MacBook

Motherboard continues running on the MacBook.

The MacBook must not possess the credential-issuance signing
private keys or independently originate human authorization.

Ellis and department agents cannot self-authorize credential
issuance or obtain unrestricted signing capability.

Compromise of the MacBook alone must not be sufficient to
produce a valid newly authorized credential issuance.

### Independent human approval — iPhone

The administrator uses an independently controlled iPhone to
review and approve each exact credential issuance request.

The intended authentication mechanism is fresh Face ID for
each issuance, backed by a Secure Enclave P-256 key.

Ordinary device-passcode fallback is not part of the selected
approval design.

Authentication and approval remain distinct: successful
biometric authentication must not silently approve a different
request or grant standing issuance authority.

The exact request, signature representation, Secure Enclave
access-control configuration, device compatibility, and
no-passcode-fallback behavior require technical validation.

### Independent manifest signing — iPad

The administrator uses the existing 2018 iPad Pro 12.9-inch
(3rd generation) as a separately controlled Ed25519 signer.

The iPad must verify that the iPhone approved the same exact
issuance manifest and must require deliberate physical
confirmation before signing.

The iPad's Ed25519 private key must remain outside the
MacBook, Motherboard, Ellis, and department-agent runtimes.

Ed25519 private-key custody on this device is not represented
as directly protected by the Secure Enclave.

The residual risk of compromise of the software-held iPad
Ed25519 signing key is acknowledged as a private-use design
tradeoff, not as established production-risk acceptance.

## Exact issuance manifest

The existing approved Stage 3 issuance-manifest format is
preserved without changing its canonical serialization.

The signed bytes are the UTF-8 encoding of:

JSON.stringify([
  "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1",
  administrator_id,
  authorization_ref,
  department_id,
  "ISSUE",
  credential_id,
  credential_digest,
  issuance_id,
  approved_at,
  expires_at
])

Field order, string types, timestamp requirements, credential
digest requirements, and canonicalization rules remain
governed by:

ELLIS_STAGE3_MANIFEST_CRYPTOGRAPHIC_DESIGN.md

The Ed25519 signature representation remains:

ed25519-manifest:<key_id>:<128 lowercase hexadecimal characters>

The existing administrative-grant signature contract remains
unchanged.

## Required dual-device verification

Before credential issuance, Motherboard must verify:

1. An independently trusted iPhone approval signature.
2. An independently trusted iPad Ed25519 manifest signature.
3. Binding of both approvals to the same immutable manifest.
4. Exact administrator, department, operation, credential,
   authorization reference, issuance ID, and digest agreement.
5. Approval validity and expiration.
6. Trusted, fingerprint-pinned verification keys.
7. Current key and authorization revocation status.
8. Durable uniqueness of authorization_ref and issuance_id.
9. Atomic credential issuance and single-use authorization
   consumption.
10. Auditable provenance, rejection, recovery, and reconciliation.

No request-controlled public key may substitute for an
independently registered trusted key.

Any missing, inconsistent, expired, revoked, replayed, or
unverifiable evidence must fail closed.

## Governance boundaries

The human administrator retains issuance-approval authority.

Ellis retains exclusive department-assignment authority.

Motherboard verifies evidence and enforces the authorized
credential lifecycle.

Authentication is not approval.

Approval is not delegation.

Delegation is not execution authorization.

Credential issuance does not authorize repository mutation,
commit, push, or unrelated governance transitions.

No agent may create, approve, or replace its own authority.

## Private-use security and cost boundary

This design is selected for the administrator's private,
internal Motherboard environment.

It reuses the existing MacBook, iPhone, and iPad rather than
requiring new hardware, an HSM, or paid cloud signing services
as a prerequisite to continued design work.

This cost decision does not justify bypassing the independent
approval, signing, verification, replay-prevention, or audit
requirements.

## Remaining validation requirements

Before claiming the architecture is operational:

1. Validate iPhone Secure Enclave P-256 signing and fresh
   Face ID requirements without ordinary passcode fallback.
2. Validate the exact iPhone approval evidence contract.
3. Validate iPad Ed25519 signing and deliberate confirmation.
4. Validate cross-device binding to identical manifest bytes.
5. Validate key registration, fingerprint pinning, rotation,
   revocation, and recovery.
6. Validate single-use atomic issuance enforcement.
7. Validate host-compromise and device-compromise failure modes.
8. Validate protected audit and reconciliation evidence.
9. Reconcile this decision with existing Ellis Stage 3
   operational and governance design records.
10. Obtain separate authorization for any implementation,
    testing, key provisioning, or deployment.

These are requirements, not claims of completed validation.

## Existing-document reconciliation

This decision supersedes the earlier Mac-based manual local
signer as the selected private-use architecture.

Earlier design records remain historical evidence and must
not be silently rewritten or deleted.

The tracked document:

docs/governance/ELLIS_STAGE3_DEFERRED_INDEPENDENT_TRUST_SOURCE.md

continues to govern the unresolved production trust boundary.

Selection of the iPhone and iPad does not establish the
independent trust source in production.

Production credential issuance remains blocked wherever
the existing governance requirements demand independent
administrative provenance.

## External-use compliance gate

Before any sale, external demonstration, licensing, handoff,
or market-facing deployment, independently reassess:

- Device and signing-key custody security.
- Production residual-risk acceptance.
- Independent administrative authority.
- Recovery and incident-response requirements.
- Licensed construct usage and redistribution restrictions.
- Separation of private internal constructs from external
  self-contained agent implementations.

External versions must not depend on or expose proprietary
internal-use construct logic.

## Next-corridor discovery

This decision must be considered when investigations ask:

- What can we do next?
- What is the next Ellis corridor?
- What remains before Ellis Stage 3 closure?
- What security work is still deferred?
- Can production credential issuance be enabled?
- Is Stage 4 ready?

The next eligible Ellis Stage 3 work is evidence-first
feasibility and governance reconciliation, subject to
separate scope and authorization decisions.

No implementation or production transition is authorized
by this document.
