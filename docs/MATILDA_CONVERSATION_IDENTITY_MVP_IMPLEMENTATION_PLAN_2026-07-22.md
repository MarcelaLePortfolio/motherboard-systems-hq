# Matilda Conversation Identity MVP Implementation Plan
## Date: 2026-07-22

## Starting Baseline

Implementation planning begins from:

`bc9d9d9d`

---

# Purpose

This document defines the bounded implementation scope following the Matilda Conversation Identity investigation.

It translates validated findings into an implementation corridor.

No implementation is authorized outside this boundary.

---

# Validated Runtime Gap

Current flow:

Project Context
→ Matilda Chat
→ Interpretation Evidence Ledger
→ Living Draft

Observed issue:

Project identity exists but is not carried through the Matilda conversational runtime.

Current chat requests do not include project identity.

Current runtime uses placeholder global identifiers:

- `draft-active-conversation`
- `matilda-active-conversation`

Living Draft synthesis currently consumes globally selected IEL entries rather than project-scoped evidence.

---

# MVP Implementation Objective

Introduce project-aware conversation identity boundaries without changing governance semantics.

Target flow:

Project Context
→ Conversation Identity
→ Conversation History
→ Interpretation Evidence Ledger
→ Living Draft

---

# In Scope

Evaluate implementation of:

- Passing existing `project_id` through the Matilda chat request path.
- Replacing global conversation placeholders with project-aware identity resolution.
- Preserving IEL as an interpretation evidence layer.
- Preserving lineage identity separately from conversation identity.
- Preventing cross-project interpretation synthesis.

---

# Expected Runtime Areas

Potential implementation areas:

- `client/src/matilda-chat/MatildaChatWorkspace.tsx`
- `client/src/matilda-chat/matildaChatApi.ts`
- `routes/api-chat.ts`
- conversation persistence boundary
- Living Draft filtering boundary

Exact implementation sequence remains deferred until validation.

---

# Explicit Non-Goals

This corridor does not authorize:

- Multi-thread conversations.
- Conversation archive UX.
- Replacing Project Registry.
- Replacing Active Context.
- Changing IEL semantics.
- Storing raw conversation history inside IEL.
- Changing governance lifecycle.
- Automatic Package creation.
- Automatic Delegation or Execution.

---

# Validation Criteria

Implementation should demonstrate:

- Switching projects does not mix conversation state.
- Project identity reaches Matilda runtime.
- IEL remains interpretation evidence, not transcript storage.
- Living Draft synthesis does not combine unrelated project evidence.
- Existing governance boundaries remain unchanged.

---

# Rollback Boundary

If implementation introduces uncertainty:

- preserve current committed baseline.
- avoid schema mutation without validated need.
- preserve existing IEL and lineage behavior.
- return to this corridor boundary for reconciliation.

No implementation authorized by this document alone.
