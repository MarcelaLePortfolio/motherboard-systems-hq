
# Project Registry V2-C.3 Scope

Date: 2026-07-04

## Corridor

Project Registry V2-C.3 — Restore / Unarchive Project

## Objective

Allow previously archived projects to return to the active registry while preserving backend authority and Active Context invariants.

## Success Criteria

The operator can restore an archived project.

Restoring a project shall:

- set registrationStatus = registered

- set availabilityStatus = available

- set activeContextEligible = 1

- preserve project metadata

- preserve duplicate detection

- preserve backend validation authority

## User Experience

Archived projects are displayed separately from active projects.

Each archived project exposes a single Restore action.

Restoring a project immediately returns it to the Active Project Switcher.

Restoring a project does not automatically become Active Context.

## Preserved Invariants

- Backend remains registry authority.

- Backend remains lifecycle authority.

- Active Context changes only through the existing switch operation.

- Desktop shell remains a presentation layer.

- Browser dashboard remains fully functional.

## Out of Scope

This corridor does not include:

- Registry normalization

- Permanent deletion

- Cross-repository execution

- Desktop packaging

- Desktop branding

- Organizational Event runtime

- Atlas runtime expansion

## Rollback Anchor

HEAD: a316a238

Archive lifecycle remains the stable baseline.

