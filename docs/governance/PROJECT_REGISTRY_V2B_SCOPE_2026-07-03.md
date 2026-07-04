
# Project Registry V2-B Scope — 2026-07-03

## Status

Project Registry V2-B begins from the frozen V2-A baseline.

## Baseline

- V2-A tag: `project-registry-v2a-stable-20260703`

- Final V2-A DR: `20260703_144228`

- V2-A status: stable, documented, recoverable

## V2-B Target

Improve the Register Existing Project operator experience.

## Primary Objective

Reduce manual path-entry risk during project registration.

## In Scope

- Improve path guidance in the Register Existing Project modal.

- Add helper text or examples for valid project root paths.

- Preserve backend validation as the authority.

- Keep the existing `/api/projects/register` route.

- Keep Active Context switching behavior unchanged.

- Keep registry persistence unchanged.

## Out of Scope

- New Project workflow.

- Archive / unregister behavior.

- Automatic repository discovery.

- Cross-repository execution.

- Project metadata editor.

- Header redesign.

- Workspace terminology changes.

## Implementation Boundary

V2-B should improve the operator interface without changing the Project Registry authority model.

The backend remains authoritative for:

- path existence validation

- Git repository validation

- duplicate project root path rejection

- registry persistence

The UI may assist the operator, but must not bypass backend validation.

## First Milestone

Add safer path-entry guidance to the Register Existing Project modal.

## Success Criteria

- Operator understands that the path must point to an existing Git repository.

- Modal still displays backend validation errors.

- No regression to Cancel, Escape, or modal opacity behavior.

- No registry data pollution during validation.

