# Matilda Project-Context Evidence Trace and Observability Findings

## Date

2026-07-24

## Status

Corridor complete.

This document records the evidence-based discovery findings for Matilda project-context retrieval, response persistence, and conversation observability.

No runtime implementation, schema migration, data repair, authority-resolution engine, automated evaluation system, or UI telemetry was created during this corridor.

---

## Scope

The investigation was limited to determining:

- how project-context evidence currently reaches a Matilda conversational response;
- which parts of that lifecycle are durably preserved;
- whether retrieved evidence can later be inspected;
- whether the immediate UI transcript represents the authoritative persisted turn;
- whether existing tests protect those boundaries;
- and what minimum successor contract is supported by current evidence.

This corridor did not reopen project-scoped Conversation Identity or the historical Interpretation Evidence Ledger classification.

---

## Governing Architectural Findings

### AF-005 — Historical Runtime and Current Runtime Have Diverged

Accepted architecture establishes:

- historical runtime artifacts must not automatically represent current system behavior;
- questions about currently exposed behavior should prioritize active runtime evidence;
- historical implementation artifacts require corroboration.

### AF-010 — Context Retrieval Is Evidence, Not Authority

Accepted architecture establishes:

- project-context retrieval is an evidence-providing layer;
- retrieved artifacts remain candidate evidence;
- retrieval success does not establish authority;
- evidence retrieval, artifact classification, authority resolution, interpretation, and approved meaning must remain separate;
- retrieval must not become an automatic trust-scoring or authority-resolution engine.

These findings govern this corridor.

---

## Verified Active Runtime Sequence

The active `/api/chat` path currently performs the following sequence:

1. Validate the project and conversation identifiers.
2. Require the requested conversation to be active for the project.
3. Run `runMatildaStub()`.
4. Create an upstream Interpretation Evidence Ledger entry.
5. Attempt Living Draft synthesis from conversation-scoped IEL evidence.
6. Resolve the registered project root.
7. Retrieve bounded project-context excerpts.
8. Load recent conversation history.
9. Send history, retrieved excerpts, and any retrieval warning to `ollamaChat()`.
10. Receive the final conversational reply.
11. Persist a conversation turn containing the user message, assistant reply, and IEL entry identifier.
12. Return the API response.

The resulting lifecycle is therefore:

```text
user interaction
→ upstream IEL evidence
→ Living Draft synthesis attempt
→ project-context retrieval
→ model response
→ durable conversation turn
→ API response
→ client transcript update
```

---

## Project-Context Retrieval Findings

Active retrieval is implemented in:

`server/matilda-project-context-retrieval.ts`

The retriever currently:

- validates the registered project root as a Git repository;
- extracts up to eight normalized query terms;
- searches bounded allowed roots with `git grep`;
- excludes known archive, generated, backup, and candidate-preview paths;
- ranks matches using path and matched-line relevance;
- selects up to three runtime sources and three documentation sources;
- reads bounded excerpts;
- returns up to six excerpts.

Each excerpt currently preserves in memory:

- `projectId`
- `relativePath`
- `lineNumber`
- `excerpt`
- `provenance: git_tracked_project_file`
- `authorityStatus: candidate_evidence_not_authority`

The overall result also contains:

- project root availability;
- whether retrieval searched;
- query terms;
- excerpts;
- warning state.

---

## Reproduced Evidence Conflict

The stored Matilda conversation examined during this corridor answered that durable project-scoped conversation identity was not implemented.

That answer contradicted the active runtime state already validated in the repository.

Reproducing retrieval for the same question selected both:

### Current implementation evidence

- `db/matilda-conversation-lineage.test.ts`
- `db/matilda-conversation-runtime.ts`
- `client/src/matilda-chat/matildaChatApi.ts`

### Historical discovery and planning evidence

- `docs/MATILDA_CONVERSATION_IDENTITY_DECISION_2026-07-22.md`
- `docs/MATILDA_CONVERSATION_IDENTITY_FINDINGS_2026-07-22.md`
- `docs/MATILDA_CONVERSATION_IDENTITY_IEL_RELATIONSHIP_OPTIONS_2026-07-22.md`

The July 22 findings document accurately described the gap at the time it was written, but that gap was later implemented and validated.

The later validation document explicitly states:

- the July 22 materials remain historical discovery records;
- it records validated runtime state;
- project-scoped Conversation Identity is no longer an unimplemented architectural gap.

The retriever presented current runtime evidence and historical discovery evidence under the same candidate-evidence authority label.

This behavior is consistent with AF-010 because retrieval is not responsible for deciding authority.

The missing boundary occurs after retrieval: artifact lifecycle and runtime authority were not structurally resolved or durably preserved before the final interpretation was produced.

---

## Existing Prompt Safeguards

The Ollama prompt already warns that:

- retrieved excerpts are candidate evidence;
- planning and no-implementation documents may be historical;
- documents alone should not prove that a capability is absent;
- uncertainty should be stated when current state cannot be established;
- conflicts should not produce unsupported certainty.

Those prose safeguards did not prevent the reproduced inaccurate answer.

Current evidence therefore supports:

> Prompt warnings alone are insufficient when a small conversational model receives structurally conflicting evidence without explicit lifecycle classification or authority-resolution metadata.

This finding does not authorize automatic trust scoring.

---

## Git Provenance Availability

Stable Git provenance was available for every reproduced source.

Current runtime files were last modified by commits dated July 23, 2026.

The historical findings, decision, and relationship-options documents were last modified by commits dated July 22, 2026.

This confirms that future evidence records can obtain source commit and commit-date metadata from the existing repository.

Commit recency alone must not be treated as authority.

A newer artifact may still be proposed, incomplete, non-authoritative, or unrelated to the active runtime.

---

## Artifact Lifecycle Metadata Availability

The inspected documentation already contains explicit lifecycle language.

Examples include:

- “No implementation is authorized by this decision alone.”
- “It evaluates relationship models before implementation.”
- “No schema changes, database migrations, or implementation are authorized by this document alone.”
- “These documents remain valid as discovery records.”
- “This document records validated runtime state only.”
- “Conversation Identity is no longer an unimplemented architectural gap.”

This confirms that useful lifecycle classification can often be grounded in explicit artifact content rather than inferred only from filenames or dates.

No active general artifact-classification mechanism was found in the runtime.

---

## Interpretation Evidence Ledger Boundary

The active IEL entry created by `runMatildaStub()` records:

- actor;
- project identity;
- conversation identity;
- the raw user message;
- generic upstream interpretation-event language;
- generic lifecycle observations;
- generic unresolved questions;
- static lineage references;
- `supersession_status`.

The IEL entry is created before:

- project-context retrieval;
- the Ollama response;
- the final conversation turn.

Its `supersession_status` field is persisted and returned by ledger listing, but current active code does not use that field for:

- retrieved-source classification;
- retrieval ranking;
- prompt construction;
- source conflict detection;
- runtime authority resolution.

The field classifies the IEL entry itself, not the repository evidence used to produce a response.

---

## Living Draft Boundary

Living Draft synthesis currently runs immediately after the upstream IEL entry is created and before project-context retrieval or the final response.

The resulting Draft therefore does not preserve:

- retrieved project sources;
- retrieval query terms;
- source conflicts;
- the final assistant response;
- the model’s interpretation of the evidence;
- runtime-authority resolution.

The current Living Draft is a conversation-scoped evidence manifest with generic lifecycle language.

This is not a database failure.

It is the current bounded synthesis behavior.

---

## Missing Durable Causal Trace

Project-context retrieval directly influences the final Ollama prompt.

However, the retrieval result is not durably linked to:

- the IEL entry;
- the Living Draft;
- the persisted conversation turn;
- the API response;
- or a separate observability artifact.

The system therefore preserves:

- that an upstream interaction occurred;
- what the user and Matilda said;
- structural lineage between the turn, IEL, and Draft.

It does not preserve:

- which project evidence was retrieved;
- why those sources were selected;
- which source conflicts were present;
- what lifecycle classifications were available;
- what authority determination, if any, informed the answer.

The best-supported finding is:

> The system currently has no durable causal record connecting project evidence retrieved for a request to the answer produced from that evidence.

---

## Pipeline Metadata Mismatches

### `draft_package_updated`

The API reports `draft_package_updated: true` when Living Draft synthesis succeeds.

That flag does not mean the Draft contains:

- the final Matilda answer;
- the retrieved sources;
- the interpretation of those sources.

It means only that the upstream IEL evidence was used to synthesize or update the current generic Living Draft.

### `meta.pipeline`

The API returns:

`pipeline: matilda-stub`

The final displayed response is produced by `ollamaChat()`.

The pipeline label therefore identifies the upstream IEL stub stage, not the complete response pipeline.

### `reasoning`

The returned `reasoning` value contains operational stub facts such as:

- selected agent;
- message length;
- IEL entry creation;
- package and execution authorization flags.

It does not explain how the retrieved project evidence led to the final conversational response.

---

## Failure-Path Visibility

If Ollama response generation fails:

- the IEL entry has already been created;
- Living Draft synthesis has already been attempted;
- no conversation turn is created;
- the client receives a `503` response;
- the response does not expose the identifiers of already-preserved upstream artifacts.

Evidence-first preservation may be valid.

The current failure response does not make that partial lifecycle visible.

---

## Persisted-Turn Response Mismatch

`createMatildaConversationTurn()` creates and returns the authoritative persisted record, including:

- real `turn_id`;
- server-confirmed `project_id`;
- server-confirmed `conversation_id`;
- persisted user message;
- persisted assistant reply;
- IEL linkage;
- actual persistence timestamp.

The `/api/chat` route currently discards that return value.

It returns the upstream stub metadata instead.

---

## Client Synthetic Turn

After a successful send, the client constructs a local object named `persistedTurn`.

That object uses:

- `turn_id: pending-${interpretation_entry_id}`;
- the client’s existing project and conversation identifiers;
- the API’s message and reply;
- the upstream stub timestamp.

It does not use:

- the real persisted turn identifier;
- the server-returned persisted conversation identifier;
- the actual turn-persistence timestamp.

The synthetic object is then appended directly to the visible transcript.

---

## No Automatic Post-Send Reconciliation

The client reloads durable chat history when:

- the active project changes;
- the user explicitly switches conversations.

It does not reload history after a normal successful message submission.

The synthetic `pending-*` turn may therefore remain visible until another project or conversation transition triggers history restoration.

The UI does not visibly mark the turn as provisional.

The immediate transcript therefore proves only that the request returned successfully.

It does not prove that the displayed object is the authoritative persisted turn.

---

## Observability Defect Classification

The synthetic-turn behavior is classified as a continuing observability defect.

It is not classified as a conversation-persistence defect because:

- the authoritative turn is created;
- the durable turn is stored;
- later history retrieval restores durable records;
- project and conversation lineage remain healthy.

The defect is the immediate divergence between durable runtime truth and the UI representation.

---

## Test Coverage Findings

The tracked repository contains no dedicated test protecting:

- `/api/chat` response shape;
- return of the authoritative persisted turn;
- retrieval-trace preservation;
- retrieval conflict visibility;
- post-send client reconciliation;
- synthetic `pending-*` turn replacement.

### Existing Matilda lineage test

`db/matilda-conversation-lineage.test.ts` validates:

- IEL and Living Draft project/conversation lineage;
- bounded lineage backfill;
- cross-conversation evidence isolation.

It does not exercise:

- the Express chat route;
- project-context retrieval;
- Ollama prompt construction;
- the API response;
- the React client.

The existing lineage test passed with:

```text
npx ts-node \
  --compiler-options '{"module":"CommonJS","moduleResolution":"Node"}' \
  db/matilda-conversation-lineage.test.ts
```

### Legacy chat smoke script

`scripts/test-matilda-chat.sh`:

- defaults to port `8080`;
- sends only `message` and `agent`;
- does not send required `project_id` or `conversation_id`;
- does not validate the active conversation contract.

It is not evidence of current chat-route coverage.

### Test-runner boundary

The repository:

- uses `node:test` in existing backend tests;
- has no root `test` package script;
- excludes `*.test.ts` and `*.spec.ts` from the root TypeScript build;
- has no client test runner or client testing dependencies.

Direct Node 24 execution of the mixed-module lineage test failed before assertions because Node interpreted the file as ESM while the test uses runtime `require()`.

The explicit CommonJS `ts-node` invocation passed.

The test-execution mismatch is separate from the observability defect and does not indicate a lineage regression.

---

## Activity Separation

Current evidence supports three separate activities.

### Observability

Preserves and exposes what happened.

Examples:

- lifecycle stages;
- identifiers;
- retrieved evidence;
- provenance;
- source conflicts;
- persistence outcomes.

### Inspection

Tests the reasoning artifact itself.

Examples:

- comprehension;
- coherence;
- contradiction detection.

### Evaluation

Assesses implications, plausibility, usefulness, or alignment.

Examples:

- plausibility;
- generativity;
- explanatory sufficiency;
- user alignment.

These activities must not be collapsed into one generic evaluation field.

---

## Authority Boundaries

### Matilda

Matilda interprets evidence and may revise an interpretation.

### Atlas

Atlas may eventually map:

- retrieved evidence;
- provenance;
- conflicts;
- lineage;
- the evolution of understanding.

Current evidence does not establish a final Atlas ontology or runtime responsibility.

Atlas must not silently declare semantic truth.

### User

The user remains the authority who determines whether Matilda’s interpretation:

- aligns with intent;
- requires revision;
- or is accepted despite deviation.

Formal outcome-review classifications should not automatically attach to every raw chat response without a governed review checkpoint.

---

## Minimum Future Evidence-Trace Boundary

Current evidence supports preserving or exposing the following minimum data for a Matilda response.

### Interaction identity

- project ID;
- conversation ID;
- IEL entry ID;
- authoritative turn ID;
- request or trace ID.

### Retrieval execution

- whether the project root was available;
- whether retrieval ran;
- query terms;
- warning or empty-result state.

### Retrieved source evidence

- relative path;
- excerpt start and end lines;
- bounded excerpt or durable excerpt reference;
- Git provenance;
- source commit;
- commit date;
- working-tree status where material;
- source-selection score or reason.

### Artifact lifecycle

- runtime source;
- test;
- current validation;
- historical discovery record;
- decision;
- proposal;
- deferred work;
- unknown or unclassified.

These are candidate classifications, not automatic authority conclusions.

### Conflict visibility

- whether retrieved sources materially disagree;
- which sources participate in the conflict;
- whether active runtime corroboration was available;
- whether authority remained unresolved.

### Lifecycle-stage outcomes

- upstream evidence preserved;
- Draft synthesis attempted and result;
- project context retrieved and result;
- model response attempted and result;
- conversation turn persisted and result;
- API response returned.

### Response truth

A successful response should return the authoritative persisted conversation-turn record or explicitly report that turn persistence did not complete.

---

## What This Corridor Establishes

- Conversation persistence remains healthy.
- IEL, turn, and Living Draft structural lineage remains healthy.
- Retrieval is functioning as a bounded evidence provider.
- Retrieval correctly does not claim authority.
- Current runtime and historical discovery evidence can be retrieved together.
- Prompt warnings alone did not prevent a stale-state answer.
- Retrieved evidence is not durably connected to the resulting answer.
- The API discards the authoritative persisted turn record.
- The client substitutes an unreconciled synthetic turn.
- Existing tests do not protect the response and observability boundaries.

---

## What This Corridor Does Not Establish

- A final retrieval-trace schema.
- A final persistence location.
- A final Atlas responsibility model.
- An automated source-trust score.
- An authority-resolution engine.
- A universal artifact-classification ontology.
- A formal review checkpoint for every chat turn.
- A client testing framework.
- A repository-wide test runner.
- That commit recency alone determines truth.
- That historical documents should be excluded from retrieval.

---

## Stabilized

- Retrieval is evidence, not authority.
- Active runtime evidence has priority for currently exposed behavior.
- Historical artifacts require corroboration.
- Historical discovery records remain valid records of prior state.
- Candidate evidence must not silently become current authoritative truth.
- Observability, inspection, and evaluation remain separate.
- Durable runtime truth must not be replaced by an unlabeled synthetic UI representation.
- The 18 historical unlinked IEL entries remain outside this corridor.

---

## Missing

- Durable per-response retrieval provenance.
- Artifact lifecycle classification.
- Observable source conflict.
- A separate authority-resolution result.
- Real persisted-turn return from `/api/chat`.
- Post-send reconciliation or direct use of the authoritative returned turn.
- Regression coverage for the active response contract.
- A later governed inspection and evaluation boundary.

---

## Deferred Work

Deferred and not authorized by this finding alone:

- richer conversation summarization;
- long-term context compression;
- conversation memory strategy;
- automated quality scoring;
- automatic artifact trust scoring;
- formal acceptance and revision workflow;
- longitudinal review-friction metrics;
- full Atlas observability ontology;
- client testing-stack selection;
- repository-wide test-command standardization;
- cleanup or replacement of historical chat scripts.

---

## Out of Scope

- Reopening Conversation Identity.
- Altering the 18 historical IEL entries.
- Making retrieval authoritative.
- Excluding all historical documents from retrieval.
- Allowing Atlas to determine semantic truth.
- Adding formal review fields directly to raw conversation turns.
- Creating dashboard telemetry before defining an evidence contract.
- Changing root module type to make one test invocation work.
- Broad test-runner or package-script restructuring.
- Speculative schema redesign.

---

## Proposed Implementation

None.

The evidence supports a successor implementation corridor, but this findings document does not authorize implementation.

Any future implementation must begin with a separately approved minimum evidence-trace contract.

---

## Current Scope Boundary

The project-context evidence-trace and observability discovery corridor is complete.

The next bounded corridor may define:

> The minimum durable project-context evidence trace and response contract required to inspect a persisted Matilda answer without reconstructing its prompt manually.

That successor corridor must preserve the separation between:

- retrieval;
- artifact classification;
- authority resolution;
- interpretation;
- approved meaning.

It must not reopen Conversation Identity or treat retrieval as an authority engine.
