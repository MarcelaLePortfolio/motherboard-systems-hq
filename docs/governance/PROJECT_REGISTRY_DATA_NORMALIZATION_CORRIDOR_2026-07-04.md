
# Project Registry Data Normalization Corridor

Date: 2026-07-04

## Background

Validation of the Project Registry V2-C native folder picker revealed two styles of registered project roots:

Bootstrap registration:

- projectRootPath = "."

- gitRepositoryReference = "."

Production registration:

- Canonical absolute filesystem path

- Canonical Git repository root

Both function correctly, but they represent project roots differently.

## Finding

The current registry contains legacy bootstrap entries alongside production-quality registrations.

This is not a V2-C defect.

It is a registry normalization opportunity.

## Goal

Introduce a one-time normalization corridor that migrates legacy bootstrap registrations to canonical project roots.

## Scope

Normalization may include:

- Canonical absolute projectRootPath

- Canonical gitRepositoryReference

- Stable duplicate comparison

- Stable Active Context references

## Out of Scope

This corridor does not change:

- Registration authority

- Backend validation authority

- Active Context authority

- Project Registry V2-C desktop implementation

## Success Criteria

After normalization:

- All registered projects use the same canonical representation.

- Duplicate detection compares normalized roots.

- Bootstrap placeholders are no longer required.

## Priority

Deferred.

Begin only after Project Registry V2-C is complete and stable.

