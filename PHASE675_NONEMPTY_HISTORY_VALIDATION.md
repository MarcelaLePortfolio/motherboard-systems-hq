PHASE 675 — NON-EMPTY HISTORY VALIDATION

Status:
- Runtime shadow endpoint already validated
- This checkpoint confirms guidance history was seeded before validation

Expected:
- /api/guidance called before validation
- /api/guidance/coherence-shadow returns raw guidance history when available
- Coherent output derives from real Express guidance history

Runtime Impact:
- No execution mutation
- No SSE mutation
- No UI mutation
- No formatting mutation
