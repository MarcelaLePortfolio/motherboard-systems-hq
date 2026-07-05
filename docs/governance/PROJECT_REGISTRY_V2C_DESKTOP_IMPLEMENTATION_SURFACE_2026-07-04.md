
# Project Registry V2-C Desktop Implementation Surface

Date: 2026-07-04  

Repository: motherboard-systems-hq  

Branch: feature/backup-system-v2  

Baseline HEAD: d1f26d8b

## Decision

Create a new top-level `desktop/` directory for the Project Registry V2-C desktop shell.

## Reason

The repository does not currently contain a dedicated desktop application surface.

Electron implementation files should remain isolated from:

- `server/`

- `routes/`

- `public/`

- `dashboard/`

- existing governance and runtime directories

This preserves the V2-B browser dashboard and backend validation model while allowing a desktop wrapper to be introduced safely.

## Desktop Surface Ownership

The `desktop/` directory may contain:

- Electron main process code

- Electron preload bridge code

- Desktop window lifecycle code

- Native folder picker bridge code

- Desktop-specific documentation or scripts

The `desktop/` directory must not contain:

- Registry persistence logic

- Backend validation authority

- Direct registry mutation logic

- Cross-repository execution logic

- Atlas runtime expansion

- Commercial Motherboard implementation

## Integration Boundary

The desktop shell should load or launch the existing local dashboard.

The desktop shell may provide native folder selection.

The selected folder path must flow back into the existing Project Registry UI and then through the existing backend endpoints:

- `/api/projects/inspect-path`

- `/api/projects/register`

## Preserved Baseline

Project Registry V2-B remains frozen.

The existing browser dashboard must continue working independently of the desktop shell.

## Next Implementation Milestone

Create the minimum `desktop/` scaffold required to open the existing dashboard without changing registration behavior.

