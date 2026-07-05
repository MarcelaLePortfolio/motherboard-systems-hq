
# Project Registry V2-C Desktop Shell Decision

Date: 2026-07-04  

Repository: motherboard-systems-hq  

Branch: feature/backup-system-v2  

Baseline HEAD: d2cb810d

## Decision

Use Electron as the first desktop shell candidate for Project Registry V2-C.

## Reason

The current project is already a Node/Express local application served by `server.mjs`.

The repository does not currently show an existing desktop shell in `package.json`.

Electron is the smallest compatible first shell because it can wrap the existing local dashboard and provide native filesystem dialogs without requiring a separate Rust or native toolchain.

## Boundary

Electron may provide desktop windowing and native folder selection.

Electron must not become registration authority.

Selected folders must still flow through:

- `/api/projects/inspect-path`

- `/api/projects/register`

## Preserved Invariants

- Backend validation remains authoritative.

- V2-B registration behavior remains frozen.

- Manual path entry remains supported.

- Safe autofill remains preserved.

- Desktop shell logic must not directly mutate registry state.

## Next Milestone

Create the smallest Electron wrapper that launches or loads the existing local dashboard without changing Project Registry behavior.

