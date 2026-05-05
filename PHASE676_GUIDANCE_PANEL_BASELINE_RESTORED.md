PHASE 676 — GUIDANCE PANEL BASELINE RESTORED

Status:
- Active UI owner confirmed: app/components/GuidancePanel.tsx
- Stray duplicated retry code removed
- GuidancePanel restored to clean baseline before coherence UI exposure

Runtime Impact:
- No execution mutation
- No SSE mutation
- No /api/guidance mutation
- No coherence promotion
- UI coherence exposure not added yet

Next:
- Validate rebuilt container
- Then add additive read-only coherence preview UI
