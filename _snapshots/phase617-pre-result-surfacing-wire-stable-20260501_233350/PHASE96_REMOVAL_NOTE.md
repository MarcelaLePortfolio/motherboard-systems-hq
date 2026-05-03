Phase 96 cleanup target (post-verification)

Remove legacy System Health Diagnostics card from dashboard.

Reason:
Operator Guidance panel in Matilda workspace now provides the interpreted cognition surface.
The top card is now redundant and was retained only for runtime verification safety.

Removal scope (must remove together):
- public/dashboard.html:
  - <section id="system-health-diagnostics-card">
  - <pre id="system-health-content">
  - SYSTEM_HEALTH_ENDPOINT script block
  - SYSTEM_HEALTH_TARGET_ID references
  - updatePanel("/diagnostics/system-health") usage

Do NOT remove:
- /diagnostics/system-health route
- operator guidance SSE
- cognition reducers

Removal must be its own commit:
"Phase 96: remove legacy system health diagnostics dashboard card"

Pre-removal checks:
- Operator guidance panel stable after restart
- SSE stream reconnect verified
- No DOM references remaining

Status:
READY FOR REMOVAL AFTER PHASE 96 RUNTIME STABILITY PASS
