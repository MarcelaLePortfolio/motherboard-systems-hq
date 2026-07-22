# Matilda Conversation Identity Findings
## Date: 2026-07-22

## Discovery Context

During MVP validation of Matilda conversational behavior, project switching was tested through the Project Context system.

The investigation confirmed that project switching correctly updates Active Context, but conversational state is not scoped to projects.

Observed behavior:

- Switching projects correctly changes the active project context.
- The visible Matilda conversation remains unchanged after project switching.
- Returning to a previously selected project does not restore a project-specific conversation.
- Chat interactions do not currently have a durable conversation identity.

This investigation determined that the missing capability is a Conversation Identity layer between Project Context and persisted Matilda interpretation.

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

## Chat Runtime

Validated:

- `routes/api-chat.ts`
- `matilda-chat-stub.ts`

Findings:

- Chat requests create Interpretation Evidence Ledger entries.
- IEL persistence exists.
- Chat requests do not currently include project identity or conversation identity.
- Current chat integration uses placeholder identifiers:
  - `draft-active-conversation`
  - `matilda-active-conversation`

Current behavior:

Chat interaction
→ placeholder draft/lineage identifiers
→ IEL entry

---

## Existing Persistence Layers

Validated:

- `db/main.db`
- `motherboard.sqlite`

Existing cognition/context persistence:

- Project Registry
- Active Context
- Interpretation Evidence Ledger
- Living Draft Packages

Existing governance lifecycle persistence:

- Canonical Packages
- Delegations
- Validations
- Envelopes
- Routing
- Assignments

---

# Validated Architectural Finding

The missing primitive is:

Project Context
→ Conversation Identity
→ Conversation History
→ Interpretation Evidence Ledger
→ Living Draft

The system currently has:

Project Context
→ Matilda Chat
→ IEL

The missing boundary is the conversation layer.

---

# Relationship Between Identifiers

Current concepts:

## Project Identity

Represents:

"What workspace/project is active?"

Example:

`project_id`

---

## Conversation Identity

Future concept:

"What ongoing human interaction belongs to this project?"

Example:

`conversation_id`

---

## Lineage Identity

Existing concept:

"What lifecycle artifacts evolved from this interpretation?"

Example:

`lineage_id`

These concepts should remain separate.

Conversation identity should not replace lineage identity.

---

# Architectural Requirement

Project switching should preserve independent conversation state.

Expected behavior:

Project A selected
→ Project A conversation restored

Project B selected
→ Project B conversation restored

Returning to Project A
→ Project A conversation resumes

---

# Storage Boundary Finding

Conversation persistence belongs conceptually with `db/main.db`.

Reason:

`db/main.db` currently contains:

- project_registry
- active_context
- interpretation evidence
- living drafts

`motherboard.sqlite` contains governance lifecycle artifacts.

Conversation identity is part of the cognition/context layer, not execution governance.

---

# Explicit Non-Goals

This finding does not propose:

- Rebuilding Project Registry
- Replacing Active Context
- Replacing IEL
- Replacing lineage_id
- Changing governance lifecycle
- Implementing conversation persistence yet

---

# Deferred Corridor

Future implementation should evaluate:

- Conversation identity model
- Message persistence model
- Project-to-conversation relationship
- Matilda context hydration
- Migration from React-only conversation state to persisted state

No implementation authorized by this finding alone.
