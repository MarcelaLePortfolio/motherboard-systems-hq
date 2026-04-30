Telemetry Model Specification

1. System Metrics (Global Scope)
Definition:
Represents the overall health and operational state of the system.

Includes:
- Worker status (running / idle / error)
- API health (latency, uptime, responsiveness)
- Database connectivity and integrity
- Execution pipeline state
- System-wide performance signals

Purpose:
Provides a single, global view of system health and stability.

---

2. Task Telemetry (Local Scope)
Definition:
Represents the lifecycle and state transitions of individual tasks.

Includes:
- Task state (queued → running → completed → failed)
- Retry attempts and failure reasons
- Execution timestamps
- Task-specific logs or metadata

Purpose:
Tracks per-task execution history and behavior.

---

3. Event Stream (Raw Execution Layer)
Definition:
Unfiltered chronological stream of system and task events.

Includes:
- Worker claim events
- Execution start/completion events
- DB state transitions
- System signals and logs

Purpose:
Source-of-truth for reconstructing system behavior over time.

---

4. UI Mapping Rules
- System Metrics → Top-level dashboard only
- Task Telemetry → Task History / Lifecycle views
- Event Stream → Telemetry Console (raw or developer view)

Rule:
No metric type should appear in more than one UI abstraction layer unless explicitly labeled by scope.

---

5. Future Toggle (Reserved)
TELEMETRY_MODE:
- combined (current state)
- separated (future refactor mode)

Purpose:
Enables controlled migration from combined UI to separated observability layers without backend disruption.

---

6. Design Principle
Separation of scope > separation of data.
