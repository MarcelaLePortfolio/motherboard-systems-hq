# Shared Interpretation Workflow Extraction

Status: Authorized Implementation Corridor

Branch: feature/new-ui-shell

Protected Baseline:

- Commit: bf903aa0
- DR: 20260802_145429

---

# Architectural Discovery

Inspection of the existing implementation demonstrates that Request Changes does not require a second interpretation pipeline.

Instead, the existing Matilda chat orchestration should become a reusable server workflow.

The workflow already composes:

- project-context retrieval
- conversation history retrieval
- conversational model invocation
- conversation persistence
- Living Draft synthesis

Only the HTTP entry point differs.

---

# Shared Workflow

Extract:

POST /api/chat

↓

Shared Interpretation Workflow

↓

Conversation History

↓

LLM

↓

Conversation Turn Persistence

↓

Living Draft Update

↓

Return Runtime Result

Both:

- POST /api/chat
- POST /api/request-changes

must invoke this shared workflow.

---

# Phase 1

Only:

Extract orchestration.

Do not change runtime behavior.

POST /api/chat must continue producing identical results.

---

# Phase 2

Only after Phase 1 is independently validated:

Introduce:

POST /api/request-changes

The endpoint becomes another caller of the shared workflow.

No interpretation logic may exist inside the endpoint.

---

# Authorized Production Scope

Phase 1 authorizes only:

- server/matilda-chat-workflow.ts (new)
- routes/api-chat.ts

No other production files.

---

# Validation

Verify:

✓ POST /api/chat behavior unchanged.

✓ Conversation persistence unchanged.

✓ Living Draft updates unchanged.

✓ Client build succeeds.

✓ Existing runtime tests succeed.

✓ No duplicate interpretation logic exists.

---

# Stop Conditions

Stop immediately if extraction requires:

- conversation runtime redesign
- Living Draft redesign
- interpretation runtime redesign
- duplicate orchestration
- endpoint-specific interpretation logic

If encountered:

1. Preserve the implementation state.
2. Document the discovery.
3. Reassess before continuing.

---

# Engineering Principle

Extract orchestration.

Do not duplicate orchestration.

Endpoints become thin wrappers around a shared authoritative workflow.

