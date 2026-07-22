# Matilda Project-Scoped Conversation Findings
## Date: 2026-07-22

## Discovery Context

During MVP validation of Matilda conversational behavior, project switching was tested through the Project Context system.

Observed behavior:

- Switching projects correctly changes the active project context.
- The visible Matilda conversation does not change when the active project changes.
- A new Matilda conversation begins without awareness of prior conversational turns.

This investigation determined that the issue is not project context switching. The missing capability is a project-scoped conversation identity layer.

---

# Evidence Reviewed

## Project Context

Validated:

- `client/src/project-context/ProjectContextProvider.tsx`
- `client/src/project-context/projectRegistryApi.ts`
- `server/project-registry.mjs`

Findings:

- Active project state is persisted through server-side `active_context`.
- Project identity is represented through `project_id`.
- Project switching updates server state through `/api/projects/active`.

Current flow:

Project selection
→ active_context update
→ registry refresh
→ UI context update

---

## Matilda Chat Workspace

Validated:

- `client/src/matilda-chat/MatildaChatWorkspace.tsx`

Finding:

Conversation display state currently exists only in React component state.

Current behavior:

Browser component state
→ visible conversation

No durable conversation identity exists.

---

## Chat API

Validated:

- `routes/api-chat.ts`
- `matilda-chat-stub.ts`

Findings:

- Chat requests create Interpretation Evidence Ledger entries.
- IEL persistence exists.
- Chat requests do not currently include project identity or conversation identity.
- Each request is effectively independent from previous conversational turns.

---

## Existing Persistence Layers

Validated:

- `db/main.db`
- `motherboard.sqlite`

Existing persisted primitives:

- Project Registry
- Active Context
- Interpretation Evidence Ledger
- Living Draft Packages
- Governance lifecycle artifacts

No conversation/message persistence tables were found.

---

# Validated Architectural Finding

The missing primitive is:

Project Context
→ Conversation Identity
→ Conversation History
→ Matilda Interpretation
→ Living Draft

The system currently has:

Project Context
→ Matilda Chat
→ IEL

The missing boundary is the conversation layer.

---

# Architectural Requirement

Project switching should not clear conversation state.

Expected behavior:

Project A selected
→ Project A conversation restored

Project B selected
→ Project B conversation restored

Returning to Project A
→ Project A conversation resumes

---

# Explicit Non-Goals

This finding does not propose:

- Rebuilding Project Registry
- Replacing Active Context
- Replacing IEL
- Changing governance lifecycle
- Clearing chat state on project switch

---

# Deferred Corridor

Future implementation should evaluate:

- Conversation identity model
- Message persistence model
- Project-to-conversation relationship
- Matilda context hydration
- Migration of chat UI state from local React state to persisted conversation state

No implementation authorized by this finding alone.
