# Architectural Decision: Ellis-Independent Downstream Development

Status: DECISION RECORDED — IMPLEMENTATION NOT YET AUTHORIZED
Date: 2026-10-23
Scope: Motherboard HQ lifecycle, scheduler, runtime, and governed execution pipeline

## Decision

Continue bounded downstream development and isolated validation without first completing Ellis Stage 3 production credential infrastructure.

This decision does not bypass, disable, weaken, or replace the Ellis production security boundary.

## Context

Ellis Stage 3 remains deferred because production credential issuance and its supporting trust infrastructure have not been established.

The existing downstream pipeline already contains lifecycle, scheduler, runtime, finalization, and governed-execution compositions.

Read-only investigation identified existing isolated handoff success tests, but those tests substitute a successful governance-execution response. Terminal composition tests establish fail-closed behavior without proving a successful integrated handoff.

## Justification

Requiring completion of Ellis production credential infrastructure before validating independently testable downstream components would unnecessarily block development.

Controlled, isolated validation can establish downstream integration behavior without claiming production readiness or introducing new authority.

## Permitted Scope

- Validate existing downstream integration using isolated test fixtures.
- Use explicit no_effect intent.
- Exercise success and failure paths without real repository effects.
- Preserve durable governance lineage and approval requirements.
- Preserve existing fail-closed production admission.
- Document verified outcomes and remaining gaps.

## Prohibited Scope

- Bypassing production Ellis identity or acknowledgement verification.
- Issuing or simulating trusted production credentials.
- Treating caller-supplied acknowledgements as verified evidence.
- Granting scheduler, routing, worker, orchestration, or execution authority.
- Performing real repository commits or pushes through validation.
- Declaring the full production pipeline operational based on isolated tests.
- Reopening completed Phase 3 or Phase 4 corridors without a new justification.

## Production Integration Boundary

Production transitions requiring Ellis acknowledgement remain blocked until independently trusted department identity, assignment-bound acknowledgement provenance, credential custody, verification, revocation, audit, and recovery requirements are satisfied.

Test fixtures do not constitute production evidence.

## Next Candidate Corridor

Isolated downstream end-to-end success-path validation.

Implementation requires separate explicit authorization.

## Reassessment Trigger

Revisit this decision when Ellis Stage 3 trust infrastructure is established, when a downstream component demonstrably requires production Ellis evidence, or when integration testing reveals an architectural dependency that cannot be safely isolated.

## Authority

This record documents development sequencing only.

It does not authorize implementation, execution, repository effects, production credential issuance, or changes to governance authority.
