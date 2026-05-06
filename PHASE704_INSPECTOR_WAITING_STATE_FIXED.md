# Phase 704 — Execution Inspector Waiting State Fixed

The inspector was no longer in backend connection failure. It was showing a waiting label because the frontend ignored `hello` / `heartbeat` stream frames and only rendered connected state after task events.

Fix:
- Treat `hello` as connected stream proof.
- Treat `heartbeat` as connected stream proof.
- Replace misleading waiting/error wording with connected stream status.
- Preserve the live `/api/tasks` path as the authoritative data source for rendered rows.
