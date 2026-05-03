PHASE 624 — UI GUIDANCE SURFACING PLAN

OBJECTIVE:
Surface passive execution guidance in UI without touching execution pipeline.

CONSTRAINTS:
- READ-ONLY
- NO execution mutation
- NO API contract breakage
- UI consumes existing SSE stream only

ENTRY POINT:
- /events/task-events

CURRENT STATE:
- Passive guidance is wired to completed SSE events
- Guidance classification works
- Guidance is currently logged only

NEXT STEP:
Expose interpreted guidance alongside events for UI consumption.

SAFE APPROACH:
1. Append optional guidance field to completed SSE event payloads
2. Preserve all existing fields
3. UI reads guidance only when present

SUCCESS CRITERIA:
- Guidance visible in UI
- Execution unchanged
- SSE unchanged for existing consumers
