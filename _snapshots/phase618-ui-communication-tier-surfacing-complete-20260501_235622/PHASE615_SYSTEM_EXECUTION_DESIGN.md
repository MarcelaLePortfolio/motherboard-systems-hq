Phase 615 — System-Led Execution Design (Planning Only)

OBJECTIVE:
Design a durable, production-safe system-led execution layer based on the validated Phase 614 proof.

CURRENT STATE:
- Autonomous execution is technically proven
- Trigger loop removed to prevent uncontrolled task creation
- System remains stable and reactive by default

DESIGN GOALS:
1. Controlled scheduler (not raw setInterval)
2. Explicit enable/disable switch
3. Deduplication / flood protection
4. Visibility in UI (system vs user tasks)
5. Safe integration with existing pipeline (no bypass)

PROPOSED COMPONENTS:

1. SYSTEM SCHEDULER
- Runs on interval or cron-like pattern
- Centralized (single source of truth)
- Emits tasks through existing API

2. EXECUTION GUARDRAILS
- Max tasks per interval
- Cooldown window
- Optional task-type filtering

3. ENABLE / DISABLE CONTROL
- Env flag or config toggle
- Runtime-safe (no rebuild required ideally)

4. DEDUPE LAYER
- Prevent identical tasks within window
- Hash or signature-based check

5. SYSTEM TASK IDENTITY
- payload.source = "system"
- UI distinction (future)

6. OBSERVABILITY (FUTURE)
- Surface system-triggered runs in UI
- Tie into CommunicationResult later

CONSTRAINTS:
- Do NOT modify runtime in this phase
- Do NOT add scheduler yet
- Do NOT change API or worker

OUTPUT OF THIS PHASE:
- Clear architecture plan
- Safe next corridor defined

NEXT SAFE CORRIDOR:
Implement a minimal controlled scheduler with:
- enable flag
- single-task-per-interval guard

