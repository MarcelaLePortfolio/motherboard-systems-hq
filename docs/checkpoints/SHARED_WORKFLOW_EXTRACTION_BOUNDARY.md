# Shared Workflow Extraction Boundary

Status: Verified

Protected Baseline

- Branch: feature/new-ui-shell
- Commit: f78e81f2

---

## Inspection Result

The extraction boundary has been identified.

HTTP validation ends immediately before:

const result = await runMatildaStub(...)

The shared orchestration concludes immediately before:

return res.json(...)

Therefore the contiguous extraction region is:

Lines 211–317 of routes/api-chat.ts

---

## Route Responsibilities (Remain)

The route continues to own:

- Express request parsing
- request validation
- HTTP status codes
- HTTP response formatting
- exception-to-response translation

---

## Shared Workflow Responsibilities

The extracted workflow owns:

1. Matilda interpretation
2. Living Draft integration
3. project-context retrieval
4. conversation history retrieval
5. conversational model invocation
6. conversation persistence
7. workflow result construction

---

## Architectural Outcome

POST /api/chat

↓

Shared Conversation Workflow

↓

Runtime Result

↓

HTTP Response

Future:

POST /api/request-changes

↓

Shared Conversation Workflow

↓

Runtime Result

↓

HTTP Response

---

## Authorized Phase 1 Scope

Only:

- server/matilda-chat-workflow.ts (new)
- routes/api-chat.ts

No other production files.

---

## Exit Criteria

✓ Shared workflow extracted.

✓ POST /api/chat behavior unchanged.

✓ Existing tests pass.

✓ Client build succeeds.

✓ No duplicate orchestration exists.

✓ Runtime authorities remain unchanged.

---

## Next Corridor

After Phase 1 is validated:

Implement POST /api/request-changes as a second caller of the shared workflow.

