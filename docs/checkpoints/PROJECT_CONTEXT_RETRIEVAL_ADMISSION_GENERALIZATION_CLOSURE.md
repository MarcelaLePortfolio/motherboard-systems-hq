# Project Context Retrieval Admission Generalization — Closure

## Status

CLOSED

## Closure Commit

`6fb2de78cd8e0eb77fd86a936080d73a40013f6c`

Commit subject:

`Generalize project context retrieval admission`

Branch:

`feature/support-source-references-runtime`

## Verified Outcome

Project-context retrieval admission was generalized from a bounded negative suppression rule to a positive-admission contract.

Repository evidence is admitted when deterministic runtime observes positive evidence of:

1. an explicit repository-evidence request;
2. a substantive project question; or
3. a concrete project operation.

Ambiguous non-question, non-concrete project utterances default to no project-context retrieval.

## Architectural Boundary

This contract governs candidate-evidence admission only.

Matilda remains Interpretation Authority. Deterministic runtime does not acquire semantic authorship, and project-context evidence remains candidate evidence rather than authority.

Existing architectural invariants remain unchanged, including one user message → one workflow → one Ollama invocation → one IEL entry → one conversation turn → one Living Draft update, independent reply and durableInterpretation ownership, and fail-closed semantic validation.

## Deterministic Validation

Broader retrieval regression validation completed with:

- 33 tests
- 33 pass
- 0 fail
- 0 skipped/cancelled

Validated surfaces included vague requests, concrete modifications, substantive project questions, explicit repository-evidence requests, low-signal greetings, bounded excerpt metadata, retrieval origin, parent/child identity, segmentation, structural provenance, structural-unit excerpts, generic testing chatter, and the original underspecified-intent contract.

At the time of deterministic closure, no live model invocation had been used to establish the production contract.

## Post-Closure Live Dogfood Validation

A fresh UI dogfood was subsequently performed using the exact regression prompt:

`i want to start making changes to the frontend.`

### Initial Live Dogfood Result

The first post-closure live dogfood produced an incorrect repository-specific response rather than requesting clarification.

Persisted turn evidence showed:

`retrieval.searched=true`

The retrieved excerpts directly corresponded to the irrelevant repository-specific claims surfaced in Matilda's response.

Read-only runtime investigation established that the production TypeScript source contained the closed positive-admission gate, but the running backend was executing stale compiled output.

The relevant source and compiled artifact timestamps were:

- `server/matilda-project-context-retrieval.ts` — `2026-09-08 09:39:46`
- `dist/server/matilda-project-context-retrieval.js` — `2026-09-03 08:56:14`

The stale compiled artifact did not contain the new admission gate.

The running backend was:

`node dist/server/index.js`

and had been running since September 3, before the retrieval-admission implementation was built.

Therefore the initial live dogfood failure did not establish a defect in the closed source implementation. It established that the active production runtime had not yet received the rebuilt artifact.

### Runtime Activation

Repository build/start contracts were verified as:

- `npm run build` → `tsc`
- `npm start` → `node dist/server/index.js`
- TypeScript output directory → `dist`

Under explicit authorization, the repository was rebuilt through the canonical `npm run build` path.

The build completed successfully with no TypeScript errors.

The stale backend process was then restarted through the canonical production start path.

The replacement backend started successfully and reported:

`Server listening on port 3000`

No new tracked source modifications were introduced by the rebuild.

### Fresh Live Regression Pass

A new Matilda conversation was created to prevent prior conversation context from influencing the regression test.

The exact prompt was submitted again:

`i want to start making changes to the frontend.`

Matilda responded:

`Okay, let's begin working on the frontend modifications. To ensure we're aligned, could you please describe the specific changes you’d like to implement?`

Persisted runtime evidence for that fresh turn showed:

- `retrieval_available=1`
- `retrieval_searched=0`
- query terms remained available to the deterministic admission layer
- no project-context search was performed

This establishes the intended live behavior:

- the repository remained available;
- the vague frontend-change utterance was evaluated;
- deterministic project-context retrieval was not admitted;
- Matilda requested clarification instead of inventing or prematurely importing repository context.

The live regression therefore PASSED after activation of the already-committed implementation.

## Stale Runtime Finding

The post-closure dogfood exposed a deployment/runtime freshness issue separate from the retrieval-admission contract itself.

The source implementation had been committed and validated, but the active backend continued serving compiled output created before that implementation.

The observed distinction is:

`SOURCE_CONTRACT=CORRECT`

`ACTIVE_COMPILED_RUNTIME=STALE_BEFORE_REBUILD`

`ACTIVE_COMPILED_RUNTIME=UPDATED_AFTER_CANONICAL_BUILD_AND_RESTART`

`LIVE_DOGFOOD_AFTER_RUNTIME_ACTIVATION=PASS`

This finding does not reopen or alter the retrieval-admission architecture.

It records that future live validation of compiled production paths must distinguish source correctness from active compiled-runtime freshness before attributing behavior to the source contract.

## Failure Containment Record

The first generalization hypothesis attempted to detect vague modification language directly.

After three failed bounded implementation attempts, that hypothesis was reverted to the last stable baseline in accordance with the three-failed-hypothesis rule.

A different solution class—positive retrieval admission—was then implemented and validated successfully.

The subsequent initial live dogfood failure did not trigger a new implementation hypothesis because read-only investigation identified stale compiled runtime state as the cause.

No speculative source modification was layered onto the already-passing implementation.

## Remote Closure

Local and remote HEAD were verified identical at production implementation closure:

`6fb2de78cd8e0eb77fd86a936080d73a40013f6c`

Local/remote divergence at that point:

`0 0`

The production implementation is remotely closed.

The original closure document was subsequently committed and pushed separately as:

`19ee00bb06ed9cb080b2131ab97ebfe2dc6be42a`

Commit subject:

`Document project context retrieval admission closure`

The post-closure live dogfood addendum documented here does not alter the implementation commit or reopen the corridor.

## Successor Scope

Post-closure read-only investigation established no authoritative automatic successor corridor for this retrieval sequence.

`SUCCESSOR_SCOPE_DETERMINATION=COMPLETE`

`AUTOMATIC_SUCCESSOR_CORRIDOR=NONE_ESTABLISHED`

Further repository work requires a separately selected objective and fresh scope determination.

## DR Disposition

A DR checkpoint was completed after cleanup of the prior dogfood runtime artifacts and before the fresh live regression test:

`20260908_100938`

The canonical `dr` command resolves through `scripts/dr-launcher.sh` to `scripts/full_dr_pipeline.sh`, which creates a repository bundle and source snapshot on Rio Drive.

Known pre-existing worktree modifications remain outside this corridor and must not be staged, reset, cleaned, discarded, or absorbed into this closure.

## Final State

`PROJECT_CONTEXT_RETRIEVAL_ADMISSION_GENERALIZATION=CLOSED`

`DETERMINISTIC_VALIDATION=33_PASS_0_FAIL`

`LIVE_DOGFOOD_AFTER_RUNTIME_ACTIVATION=PASS`

`RETRIEVAL_AVAILABLE=TRUE`

`RETRIEVAL_SEARCHED_FOR_REGRESSION_PROMPT=FALSE`

`STALE_RUNTIME_CAUSE=CONFIRMED_AND_CORRECTED`

`ACTIVE_CORRIDOR=NONE`

`NEXT_ACTION=AWAIT_NEW_USER_SELECTED_OBJECTIVE`
