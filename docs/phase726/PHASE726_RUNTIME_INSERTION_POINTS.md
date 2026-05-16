
# Phase 726 Runtime Insertion Points — Initial Map

## Purpose

This document will capture the exact runtime files and smallest safe additive insertion points for future semantic artifact metadata.

This is a discovery artifact only.

## Current Status

Not integrated.

No Phase 726 helper is currently wired into runtime execution.

## Known Candidate Areas From Search

Likely files or areas requiring inspection:

- server/routes/api-tasks-postgres.mjs

- public/js/phase530_visible_panels_bridge.js

- worker task completion path

- artifact persistence helper path

- artifact preview route

- visual artifact metadata generation path

## Required Before Any Runtime Wiring

Before integration, confirm:

1. the current worker completion function

2. the current artifact persistence function

3. the current persisted artifact shape

4. the current preview route response shape

5. the current frontend preview parser assumptions

6. whether additive semantic metadata can be emitted without breaking legacy artifacts

## Safe Integration Preference

The preferred insertion point is after task output generation but before artifact persistence, with a guarded helper call that can fail without affecting existing output.

If that point is not clean, preserve inspect-only mode and do not integrate.

