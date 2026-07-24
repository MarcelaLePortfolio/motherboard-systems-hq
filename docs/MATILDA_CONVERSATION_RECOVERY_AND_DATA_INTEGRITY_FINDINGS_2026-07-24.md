# Matilda Conversation Recovery and Data Integrity Findings

## Date

2026-07-24

## Status

Corridor complete.

This document records the evidence-based classification of persisted Matilda conversation lineage and Interpretation Evidence Ledger state.

No source-code change, database repair, migration, deletion, speculative backfill, or runtime remediation was performed during this corridor.

---

## Scope

The investigation was limited to determining whether 18 persisted `iel-chat-*` Interpretation Evidence Ledger entries with `NULL` `project_id` and `conversation_id` represent:

- historical pre-lineage behavior,
- expected upstream evidence behavior,
- or an active runtime lineage defect.

The investigation did not authorize repair or implementation.

---

## Repository and Runtime State

Verified repository:

`/Users/marcela-dev/Projects/motherboard-systems-hq-clean`

Verified branch:

`feature/new-ui-shell`

Verified HEAD at investigation start:

`b80c4aa1d20099c52a47c2b4cddbac89d74a741a`

`docs: validate Matilda project-scoped conversation runtime boundary`

The HEAD commit was documentation-only.

Verified active runtime:

- Backend: `ts-node server/index.ts` on port `3000`
- React development shell: Vite on port `5173`
- Backend working directory: repository root
- Vite working directory: `client/`

`server/index.ts` mounts `apiChatRouter` through `app.use(apiChatRouter)`.

---

## Disaster Recovery Evidence

Latest inspected backup:

`/Volumes/Rio Drive/backups/source_20260724_113245.tar.gz`

DR status:

`PASS`

The persisted database was inspected from the backup artifact by extracting:

`files/db/main.db`

The backup contained the relevant Matilda persistence tables:

- `matilda_active_conversation_context`
- `matilda_conversation_turns`
- `matilda_conversations`
- `matilda_interpretation_evidence_ledger`
- `matilda_living_draft_packages`

---

## Persisted Database Findings

### Conversations

`matilda_conversations`

- Total rows: 7
- Rows with `project_id`: 7

### Conversation Turns

`matilda_conversation_turns`

- Total rows: 15
- Rows with `conversation_id`: 15
- Rows with `project_id`: 15
- Orphan turns referencing missing conversations: 0

### Interpretation Evidence Ledger

`matilda_interpretation_evidence_ledger`

- Total entries: 33
- Entries with `conversation_id`: 15
- Entries with `project_id`: 15
- Entries without either lineage field: 18

The 18 unlinked entries:

- use the `iel-chat-*` prefix,
- have `project_id = NULL`,
- have `conversation_id = NULL`,
- have no matching row in `matilda_conversation_turns`,
- preserve the event:

> Matilda received a chat interaction and preserved upstream interpretation evidence before any Package creation.

---

## Active Write Path

The active runtime path is:

`POST /api/chat`

→ `runMatildaStub`

→ `createInterpretationEvidenceLedgerEntry`

The extensionless route import resolves at runtime to:

`matilda-chat-stub.js`

That active JavaScript module forwards both:

- `project_id`
- `conversation_id`

Its extensionless persistence import resolves to:

`db/matilda-interpretation-runtime.ts`

The active persistence writer preserves both lineage values exactly when supplied.

The current `/api/chat` route:

1. requires non-empty `project_id` and `conversation_id`,
2. verifies that the conversation is active for the project,
3. passes both identifiers into `runMatildaStub`,
4. persists the IEL entry,
5. uses the same interpretation entry identifier for Living Draft integration,
6. persists the completed conversation turn with the same project, conversation, and interpretation entry identifiers.

The current verified write path cannot ordinarily produce an unlinked `iel-chat-*` entry.

---

## Historical Lifecycle Evidence

The unlinked entries form a continuous historical block rather than an intermittent pattern.

### Unlinked block

- First unlinked entry: `2026-07-21T22:20:46.106Z`
- Last unlinked entry: `2026-07-22T21:16:12.736Z`
- Count: 18
- Matching conversation turns: 0

### Linked block

- First linked entry: `2026-07-22T21:48:11.647Z`
- All 15 subsequent entries have:
  - `project_id`,
  - `conversation_id`,
  - and a matching conversation turn.

No linked and unlinked entries are interleaved after this transition.

---

## Relevant Repository Transitions

### Commit `35fbe8e6`

`feat: persist project chat continuity`

Commit time:

`2026-07-22T14:49:52-07:00`

This commit introduced:

- `matilda_conversation_turns`,
- `createMatildaConversationTurn`,
- storage of `interpretation_entry_id` on each turn,
- conversation history retrieval,
- turn persistence after successful `ollamaChat` completion.

The first IEL entry with a matching conversation turn was created approximately two minutes before this commit, consistent with the implementation already running from the working tree immediately before it was committed.

### Commit `bf881de1`

`feat: add project conversation identity`

This transition added explicit conversation identity to persisted turns and project-scoped conversation history.

At this stage, `/api/chat` passed `project_id` into the IEL-producing stub but did not yet pass `conversation_id` directly into that writer.

### Commit `581e1578`

`feat: add conversation controls`

This transition introduced:

- persisted active-conversation context,
- conversation creation and switching controls,
- mandatory normalized `project_id` and `conversation_id`,
- active-conversation validation before interpretation,
- conversation-scoped Living Draft identity.

### Commit `2373010a`

`feat: connect conversations to interpretation lineage`

This transition:

- added `project_id` and `conversation_id` columns to IEL persistence,
- forwarded both identifiers into IEL creation,
- added an index for conversation-scoped IEL retrieval,
- added bounded backfill from matching conversation turns.

The backfill assigns lineage only when an existing turn references the same `interpretation_entry_id`.

It does not guess ownership for entries without matching turns.

---

## Evidence-Based Classification

The best-supported classification is:

> The 18 unlinked `iel-chat-*` entries are historical upstream interpretation evidence created during the pre-turn-persistence lifecycle.

At the time those entries were created, Matilda could preserve interpretation evidence before a durable conversation turn existed to establish project and conversation lineage.

When conversation lineage was later added to IEL persistence:

- entries with matching conversation turns could be linked reliably,
- entries without matching turns remained unresolved,
- no speculative ownership was assigned.

Their unresolved lineage is therefore historical persisted state, not evidence of an active runtime defect.

---

## Verified Outcomes

- DR backup integrity was validated.
- Matilda persistence tables were confirmed in the backup.
- Conversation records are project-scoped.
- Conversation turns are project- and conversation-scoped.
- No orphan conversation turns were found.
- The active `iel-chat-*` creation path was identified.
- Runtime module resolution was verified.
- Current chat writes require valid project and conversation identity.
- The historical transition from unlinked to linked IEL behavior was identified.
- All entries after the transition have matching turns and lineage.
- The 18 historical entries were classified without altering them.

---

## Solved

- Origin path for `iel-chat-*` entries.
- Active runtime lineage behavior.
- Reason bounded backfill linked only part of the historical ledger.
- Historical versus active behavior distinction.
- Determination that current runtime repair is not justified.

---

## Stabilized

- The 18 entries are preserved historical evidence.
- They are not orphan conversation turns.
- They are not evidence of missing tables.
- They are not evidence of a current recurring lineage defect.
- Current Matilda conversation lineage is functioning across IEL, turns, and Living Draft integration.
- Unresolved lineage must not be replaced with guessed ownership.

---

## Missing

No remaining uncertainty materially blocks the classification.

The exact intended project or conversation for each of the 18 entries cannot be established from the available persisted evidence.

That absence does not impair current runtime integrity.

---

## Deferred Work

Deferred and not currently required:

- optional historical or archival labeling,
- an evidence-based backfill only if independent ownership evidence is discovered,
- broader failure-injection testing across the complete cognition lifecycle,
- recovery-order validation between IEL, conversation turns, and Living Draft persistence.

---

## Out of Scope

- Guessing project ownership.
- Guessing conversation ownership.
- Deleting historical IEL entries.
- Rewriting ledger history.
- Broad lineage migration.
- Schema redesign.
- Cleanup-driven architecture changes.
- Treating preserved upstream evidence as corruption.
- Changing Matilda authority or governance boundaries.

---

## Proposed Implementation

None.

The evidence does not justify code changes, data repair, migration, or runtime remediation.

---

## Current Scope Boundary

The Matilda interpretation-evidence lineage classification corridor is complete.

The 18 unlinked entries should remain preserved with unresolved lineage unless independent evidence later establishes their ownership.

Any successor corridor must begin from a separately defined scope and must not reopen these entries as an active defect without new contradictory evidence.
