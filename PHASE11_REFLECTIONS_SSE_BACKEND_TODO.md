# Phase 11 – Reflections SSE Backend TODO (v11.9)

## Context

Branch: feature/v11-dashboard-bundle

Current dashboard console at v11.9:

- reflections-sse-dashboard.js:
  - "[DASHBOARD REFLECTIONS] Reflections SSE backend endpoint not available; wiring is temporarily disabled. See PHASE11_REFLECTIONS_SSE_BACKEND_TODO.md for details."
- This is expected in v11.9. The Reflections SSE backend is intentionally not wired while the shim is active.
- Shim reference:
  - PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md:
    - Reflections-related files.
    - Current shim behavior.
    - Phase 11.10 activation checklist (draft).

Matilda chat console:

- matilda-chat-console.js:
  - "[matilda-chat] Matilda chat wiring complete."
- Confirms Matilda chat JS wiring is initialized.

## Current Intended Behavior (v11.9)

For v11.9, the intended state:

- Reflections SSE:
  - Backend SSE endpoint is NOT yet live.
  - Dashboard logs a single, clear warning that wiring is temporarily disabled.
  - Any EventSource to `/events/reflections` is neutralized by:
    - public/js/sse-reflections-shim.js (browser shim).

- Matilda Chat:
  - Matilda chat wiring present and initialized.
  - API/UI behavior tested separately (see PHASE11_v11.9_RUNTIME_CHECKS.md).

## Backend Wiring TODO – Phase 11.10+

Do NOT start these until Phase 11.10 is explicitly kicked off.

1. Choose Reflections SSE server implementation

   - Select a canonical server entrypoint, e.g.:
     - reflections-sse-server.ts or
     - reflection-sse-server.ts
   - Remove/archive unused variants after selection.

2. Define and validate SSE endpoint

   - Target endpoint:
     - URL: `/events/reflections`
     - Host: `127.0.0.1`
     - Port: `3200` (or updated per final design).
   - Manual test:
     - curl -N http://127.0.0.1:3200/events/reflections
     - Expect a valid SSE stream (data: ... lines, open connection).

3. Integrate backend with dashboard

   - Confirm dashboard client uses:
     - new EventSource("http://127.0.0.1:3200/events/reflections")
       or an equivalent proxied path.
   - Remove shim interception for `/events/reflections` once backend is stable:
     - Option A: Delete sse-reflections-shim.js and its script tag/import.
     - Option B: Keep shim file but stop intercepting "events/reflections" URLs.

4. Run Phase 11.10 activation checklist

   - Use:
     - PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md → "Phase 11.10 – Reflections SSE Activation Checklist".
   - After all items pass:
     - Tag a new stable baseline:
       - v11.10-reflections-sse-online-stable (or similar).

## Notes

- This file explains the reflections-sse-dashboard.js console warning as an intentional temporary state during Phase 11 v11.9.
- Future Reflections SSE work must update this file and PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md together to keep docs aligned.
