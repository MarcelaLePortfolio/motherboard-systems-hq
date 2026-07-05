
# Project Registry V2-C Desktop Bridge Phase 1

Date: 2026-07-04

## Purpose

Establish the initial desktop bridge while preserving context isolation and backend authority.

## Exposed Surface

The preload bridge currently exposes only immutable runtime metadata:

- version

- platform

- isDesktop

No filesystem APIs are exposed.

No Electron IPC is exposed.

No privileged operations are available.

## Security Boundary

The renderer cannot:

- access Node.js

- access Electron directly

- access the filesystem

- mutate registry state

The preload bridge serves only as the future expansion point for native desktop capabilities.

## Next Milestone

Expose a single, audited native folder picker API while preserving backend-authoritative registration.

