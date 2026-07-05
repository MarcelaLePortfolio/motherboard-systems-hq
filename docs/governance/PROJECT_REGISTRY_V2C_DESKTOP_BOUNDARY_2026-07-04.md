
# Project Registry V2-C Desktop Boundary

Date: 2026-07-04

Repository: motherboard-systems-hq

Branch: feature/backup-system-v2

Baseline HEAD: eb799329

Prior Stable Scope: Project Registry V2-B

## Corridor Determination

Project Registry V2-B remains frozen.

Project Registry V2-C is now defined as the desktop application foundation corridor for Project Registry operator experience.

The native folder picker is intentionally deferred to the desktop application layer rather than implemented as a browser-only enhancement.

## Reason for Boundary

The current dashboard is served locally through:

PORT=3001 node server.mjs

The current Project Registry modal exists in:

public/dashboard.html

The existing registration workflow already preserves backend-authoritative validation through:

- /api/projects/inspect-path

- /api/projects/register

A true native folder picker belongs to the future desktop shell, where filesystem access can be provided without changing backend authority.

## In Scope

- Select the desktop shell architecture.

- Preserve the existing local dashboard runtime.

- Preserve server.mjs as the local backend.

- Add native folder selection through the desktop shell.

- Feed the selected path into the existing inspection endpoint.

- Preserve backend-authoritative validation.

- Preserve manual path entry.

- Preserve safe autofill.

- Preserve the existing registration workflow.

## Out of Scope

- Browser-only showDirectoryPicker implementation.

- Fake native folder picker.

- Automatic repository discovery.

- New Project workflow.

- Archive / unregister workflow.

- Project metadata editor.

- Header redesign.

- Workspace terminology changes.

- Atlas runtime expansion.

- Cross-repository execution runtime.

- Organizational Event Model runtime.

- Commercial Motherboard implementation.

## Authority Boundary

Backend validation remains authoritative for:

- Project path existence.

- Git repository validation.

- Duplicate project rejection.

- Registry persistence.

- Active Context eligibility.

The desktop shell may assist with folder selection but must not bypass or replace backend validation.

## Implementation Principle

The desktop application should populate the existing Project Root Path input and continue using the existing inspection and registration endpoints.

No registry mutations should occur directly from desktop shell logic.

## Next Canonical Milestone

Project Registry V2-C Desktop Foundation.

Implementation planning should begin by selecting the desktop shell while preserving the existing V2-B registration workflow unchanged.

