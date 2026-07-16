# UI Final Lock

## Rule of Truth
Only ONE module may define /ui:

- server/ui-route.ts (ONLY)

## Enforcement Rule
No other file may:
- define app.get("/ui")
- define sendFile(index.html for UI)
- define fallback UI routes

## Import Rule
server/index.ts MUST NOT register UI routes directly.

## Failure Mode
If multiple UI handlers exist → system is invalid state.
