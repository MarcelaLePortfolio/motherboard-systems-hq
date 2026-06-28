
# Department Assignment Handshake Contract

## Purpose

This contract defines the minimum constitutional boundary between Ellis departmental assignment and departmental acknowledgement.

It does not authorize scheduler integration, routing integration, worker integration, execution authority, actor assignment, department runtime implementation, or participation resolution.

## Scope

This contract applies after governance has produced an authorized Envelope and Ellis has resolved the accountable department.

## Authority Boundary

Ellis owns departmental accountability assignment.

Departments own local operational acknowledgement and capability-status reporting.

Departments do not override Ellis.

Departments may report operational evidence that requires Ellis re-coordination.

## Normal Path

1. Ellis assigns an accountable department.

2. The department acknowledges accountability.

3. The department confirms no known capability conflict.

4. The lifecycle may proceed beyond departmental acknowledgement.

## Exception Path

1. Ellis assigns an accountable department.

2. The department acknowledges the assignment.

3. The department reports a capability conflict or local operational incapacity.

4. Ellis performs operational re-coordination before the lifecycle proceeds.

## Minimum Ellis Output

Ellis must produce:

- owning_department

- assignment_basis

## Minimum Department Response

A department must produce:

- acknowledgement_status

- capability_status

- capability_conflicts

- response_basis

## Valid Acknowledgement Status

- ACKNOWLEDGED

## Valid Capability Status

- CAPABILITY_CONFIRMED

- CAPABILITY_CONFLICT_REPORTED

## Constitutional Interpretation

Department acknowledgement is **not** approval of Ellis' assignment.

It is acknowledgement of departmental accountability.

Capability reporting is **not** rejection of Ellis' authority.

It is new operational evidence originating from the department's local operational state.

Ellis remains the sole Operational Coordination Authority.

## Non-Goals

This contract does not define:

- lead actor

- supporting actors

- reviewers

- temporary teams

- implementation plans

- execution plans

- scheduler slots

- routes

- worker claims

- department runtime internals

- participation-resolution mechanics

## Deferred Shape Relationship

This contract preserves DSR-001 — Department Participation Resolution.

If departmental acknowledgement requires actor-level participation decisions, DSR-001 must be re-opened before implementation proceeds beyond this contract.

## Stabilized Boundary

Ellis assigns departments.

Departments acknowledge accountability and report current capability status.

Departments determine internal participation only when that deferred implementation shape is explicitly re-opened and authorized.

Actors and teams perform implementation within departmental authority.

Workers execute only after downstream execution authority is separately authorized.

