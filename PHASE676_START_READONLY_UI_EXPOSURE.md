PHASE 676 — READ-ONLY COHERENCE UI EXPOSURE START

Starting State:
- Phase 675 final seal complete
- Express coherence shadow route validated
- Non-empty shadow output confirmed
- Containerized runtime rebuilt
- Local snapshot created
- Lightweight snapshot manifest pushed
- Working tree confirmed clean

Next Safe Corridor:
- Read-only UI exposure only

Rules:
- Do not mutate execution
- Do not mutate SSE
- Do not mutate /api/guidance
- Do not promote coherence to authoritative guidance
- Locate actual Guidance Panel owner before patching

Immediate Next Action:
- Inspect UI ownership for Guidance Panel / guidance history rendering
- Add coherence preview as additive, read-only surface only after owner is confirmed
