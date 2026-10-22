# Ellis Stage 3 — Deferred Independent Administrative Trust Source

## Status

DEFERRED — UNRESOLVED PRODUCTION SECURITY REQUIREMENT

## Unresolved issue

Motherboard has isolated authorization verification controls,
but independently authenticated human approval and signing-key
ownership have not been established for production credential issuance.

A compromised Mac administrator could potentially manipulate
authorization inputs without a separately trusted approval source.

## Decision

Defer selecting and establishing the independent administrative
authentication and signing arrangement.

This deferral does not constitute production risk acceptance,
Stage 3 closure, or authorization to bypass existing controls.

## Development boundary

Unrelated development may continue under separate authorization.

Production department credential issuance must remain blocked
where independent administrative provenance is required.

No temporary self-authorization, request-controlled authority,
or weakened verification may substitute for the missing trust source.

## Mandatory return triggers

Reopen this requirement before:

1. Enabling production department credential issuance.
2. Declaring Ellis Corridor 4 Stage 3 complete.
3. Authorizing a dependent Stage 4 production transition.
4. Accepting production risk related to administrative authority.
5. Changing the administrative credential trust architecture.

## Required resolution evidence

- Independently authenticated human administrator.
- Explicit approval bound to the exact issuance manifest.
- Independently protected Ed25519 signing-key custody.
- Trusted public verification-key registration.
- Independent revocation, audit, and recovery.
- Validation against the approved provenance criteria.
- Reconciliation of Mac administrator compromise risk.

## Governance

REQUIREMENT_STATUS=DEFERRED_UNRESOLVED
PRODUCTION_CREDENTIAL_ISSUANCE=BLOCKED_PENDING_TRUST_SOURCE
INDEPENDENT_TRUST_SOURCE=NOT_ESTABLISHED
HOST_COMPROMISE_RESIDUAL_RISK=HIGH_UNACCEPTED
PRODUCTION_RISK_ACCEPTED=NO
STAGE_3=OPEN
STAGE_3_CLOSURE=WITHHELD
STAGE_4_AUTHORIZED=NO
IMPLEMENTATION_AUTHORIZED=NO
COMMIT_AUTHORIZED=NO
PUSH_AUTHORIZED=NO
