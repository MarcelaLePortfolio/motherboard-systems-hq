Telemetry UI Decision Log

Decision:
The current Telemetry Console will retain both system-level metrics and task-level telemetry views in the same interface for now.

Rationale:
- Both system metrics and task telemetry provide distinct but complementary perspectives.
- Keeping them together preserves observability during active development and debugging.
- UI separation is deferred to a later optimization phase once execution stability and observability consistency are fully validated.

Status:
- No backend changes required
- No schema changes required
- UI refactor deferred (postponed, not discarded)

Next revisit trigger:
- When telemetry interpretation becomes confusing in practice
- Or when scaling introduces visual/semantic overload in the console
