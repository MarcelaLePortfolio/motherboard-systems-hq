
# Phase 711 — Advisory Status Validation

## Summary

Phase 711 refined Matilda advisory status behavior to reduce unsupported runtime certainty.

## Problem Observed

Before rebuild, `/api/chat` continued returning unsupported broad status claims such as:

- "All monitored subsystems are operating normally"

- "nothing actively needing attention"

This happened even after host source patches were committed.

## Root Cause

The running dashboard container was still using the older `/app/server.mjs` image contents.

Host source had changed, but the authoritative runtime had not yet been rebuilt.

## Fix Applied

Rebuilt the dashboard container:

docker compose up -d --build dashboard

## Verified Container State

The rebuilt container now includes:

- limited-certainty `latestSummary`

- explicit `certainty: limited-read-only-context`

- prompt constraints preventing broad health claims from compact context

## Validation Result

Status prompt:

What is the system status?

Returned a limited, truthful advisory response:

The surfaced context is limited, read-only, and non-authoritative. The guidance endpoint is available, but this compact context does not prove every subsystem is currently healthy. I recommend reviewing the dashboard for additional details.

Prioritization prompt:

What should we prioritize next?

Returned a limited, truthful advisory response and did not claim all systems were healthy.

## Contract Preserved

- execution: false

- systemCoupling: false

- advisory-only behavior preserved

- no worker coupling introduced

- no database mutation introduced

- no hidden execution introduced

## Lesson

For live advisory behavior changes:

1. Patch host source.

2. Commit and push.

3. Rebuild dashboard container.

4. Verify `/app/server.mjs` inside container.

5. Test `/api/chat` against port 3000.

6. Only then treat runtime behavior as validated.


---

## Final Runtime Validation Addendum

Final `/api/chat` validation passed after dashboard rebuild.

Result:

- status response no longer claims all systems are healthy

- prioritization response no longer claims nothing needs attention

- execution remains false

- systemCoupling remains false

Status response:

"The surfaced context is limited, read-only, and non-authoritative. It indicates the guidance endpoint is available, but this compact context does not prove every subsystem is currently healthy. I recommend reviewing the dashboard for any specific alerts or indicators."

Prioritization response:

"The surfaced context is limited, read-only, and non-authoritative. Based on the available information, it’s difficult to determine what to prioritize. The guidance endpoint is available, but the context doesn't confirm the health of any specific subsystems. I recommend checking the dashboard for any reported issues or alerts."

