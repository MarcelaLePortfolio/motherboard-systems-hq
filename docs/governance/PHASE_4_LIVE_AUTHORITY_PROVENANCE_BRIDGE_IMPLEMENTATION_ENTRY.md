# Phase 4 — Live Authority / Provenance Bridge Implementation Entry

## Status

- Stable implementation baseline: `b0bc937b4`
- Local/remote baseline: converged
- Architectural contract: preserved
- Bounded implementation: authorized
- Implementation commit: not authorized
- Implementation push: not authorized

## Authorized Implementation Scope

Implementation is limited to:

- the minimum live handoff/composition surfaces required for the bridge; and
- directly necessary focused tests.

No broader execution, governance, approval, or authority redesign is authorized.

## Authority Source

The only authority-bearing records remain:

- existing governance execution approval
- existing governance execution scope

The implementation must reuse the existing authoritative governance contracts rather than reconstructing authority.

## Required Provenance

Before the existing governed execution boundary may be invoked, the bridge must establish exact durable provenance for:

- canonical `package_id`
- canonical `package_version`
- canonical `lineage_id`
- durable execution plan
- durable preview
- durable preview confirmation

The complete provenance chain must correspond to the exact package/version/lineage covered by the existing governance authority.

## Required Existing Components

The implementation must reuse the existing contracts for:

- `loadGovernanceExecutionApproval`
- `loadGovernanceExecutionScope`
- canonical package/version resolution
- Matilda execution-plan loading
- Matilda preview loading
- Matilda preview-confirmation loading
- existing execution-authority core
- existing governed execution boundary

## Fail-Closed Requirements

The bridge must fail closed when required authority or provenance evidence is:

- missing
- ambiguous
- stale
- mismatched

Exact package/version and canonical lineage identity must be preserved throughout the bridge.

## Authority Boundary

Matilda provenance does not create governance authority.

Preview confirmation:

- is provenance evidence;
- is not governance approval;
- does not independently authorize execution; and
- must not create governance execution scope.

Execution-authority evaluation must not become a substitute for the existing governance approval or governance scope.

## Prohibited Approaches

The bounded implementation must not:

- reconstruct governance authority through direct SQL;
- create an alternate authority path;
- connect a legacy authority path;
- promote preview confirmation into approval;
- infer governance authority from successful provenance validation;
- bypass governance execution approval;
- bypass governance execution scope; or
- introduce new authority.

## Implementation Entry Determination

The architectural investigation is complete enough to begin the bounded live bridge implementation from baseline `b0bc937b4`.

The implementation must compose the existing authority-bearing governance contracts with the durable Matilda provenance contracts before invoking the existing governed execution boundary.

## Governing Principle

**Matilda proves provenance; governance grants authority.**

Implementation may validate that existing governance authority applies to the exact durable Matilda artifact being executed.

Implementation may not create that authority.
