# Matilda Admission Generalization Investigation — Closure

## Status

CLOSED

## Closure Baseline

Commit:

`d89b9119bca6d5d105057942bc83804898e652bc`

Commit subject:

`Clarify evidence scope comparison`

Branch:

`feature/support-source-references-runtime`

At closure, local and remote branch state were verified identical.

## Objective

Determine whether the current Matilda production architecture still contains an evidence-backed project-context admission or continuation defect requiring additional generalization work.

The investigation specifically evaluated whether the observed behavior required:

- additional pre-retrieval semantic specificity classification;
- prior-turn query-term transport into project-context retrieval;
- deterministic post-model semantic filtering; or
- another implementation hypothesis beyond the existing production contracts.

The investigation remained evidence-first and did not authorize speculative implementation.

## Hypothesis #1 — Evidence Scope Preservation

The reproduced issue established that Matilda did not correctly preserve the distinction between an already-established subset of evidence and the remaining unresolved scope.

The minimum supported correction was implemented in the prompt contract.

Commit:

`d89b9119bca6d5d105057942bc83804898e652bc`

The production instruction now requires Matilda to preserve partial-scope distinctions:

- treat an established portion as established;
- identify only the remaining uncovered scope as unresolved;
- do not describe the already-established portion itself as incomplete.

Focused regression validation passed.

Disposition:

`HYPOTHESIS_1=SUPPORTED_IMPLEMENTED_VALIDATED_COMMITTED`

## Hypothesis #2 — Prior-Turn Query Continuity

A second hypothesis proposed adding bounded prior-user-message query terms to project-context retrieval while preserving current-message terms as primary.

The change was implemented locally and validated in isolation.

Under explicit authorization, the locally validated build was activated for live dogfood without staging, committing, or pushing the hypothesis.

### Live Dogfood Result

A fresh three-turn conversation reproduced the governing Packages-removal scenario.

Turn 2 retrieved the canonical removal-gate project evidence.

Turn 3 correctly concluded that the removal gate was satisfied after the user reported completing the required browser validation.

Inspection established:

- Turn 2 project-context retrieval supplied the governing removal-gate evidence.
- That context persisted through normal conversation history.
- Turn 3 did not use project-context retrieval.
- Turn 3 was behaviorally correct.
- Existing selected conversation-history continuity was sufficient for the reproduced scenario.

Therefore the successful result did not establish causal benefit from the Hypothesis #2 retrieval modification.

### Revert

Hypothesis #2 was classified:

`ABANDON_AND_REVERT`

The production source modification and focused untracked regression test were removed.

The exact clean baseline was rebuilt in isolation and restored to the active Matilda backend.

Clean-baseline dogfood reproduced the same correct continuation behavior without Hypothesis #2.

Disposition:

`HYPOTHESIS_2=ABANDONED_NON_CAUSAL_AND_REMOVED`

`HYPOTHESIS_2_CAUSAL_BENEFIT=NOT_ESTABLISHED`

`HYPOTHESIS_2_COMMIT_JUSTIFIED=NO`

## Hypothesis #3 — Successor Production Contract Review

The third investigation asked whether the apparent semantic-admission gap represented a current defect or a historical problem already superseded by later production architecture.

Repository lineage established:

- Adaptive Detail corridor closure: `69a26c738`
- retrieval-origin production contract: `c897a99bd`
- positional selected-context production contract: `581be85eb`

All three commits are ancestors of the current baseline.

Focused current-contract regression validation covered:

- positional runtime-owned identity resolution;
- deterministic duplicate-position handling;
- fail-closed out-of-range handling;
- fail-closed non-integer handling;
- retrieval-origin presentation as non-semantic provenance;
- exclusion of retrieval origin from model-authored positional identity;
- preservation of child retrieval origin;
- retrieval-origin ordering neutrality.

Result:

`8 PASS / 0 FAIL`

No current successor-contract failure was reproduced.

Disposition:

`HYPOTHESIS_3=CLOSED_NO_CURRENT_FAILURE`

`NEW_PRE_RETRIEVAL_CLASSIFIER_JUSTIFIED=NO`

`DETERMINISTIC_POST_MODEL_SEMANTIC_FILTERING_JUSTIFIED=NO`

## Parent Investigation Determination

Across the completed investigation:

`HYPOTHESIS_1=RESOLVED`

`HYPOTHESIS_2=ABANDONED_NON_CAUSAL_AND_REMOVED`

`HYPOTHESIS_3=CLOSED_NO_CURRENT_FAILURE`

No distinct remaining project-context admission failure was reproduced.

No distinct remaining continuation failure was reproduced.

No current successor-contract regression was reproduced.

Therefore:

`ADMISSION_GENERALIZATION_INVESTIGATION=RESOLVED_WITHOUT_ADDITIONAL_IMPLEMENTATION`

`DISTINCT_REMAINING_REPRODUCED_FAILURE=NONE`

`FURTHER_HYPOTHESIS_JUSTIFIED=NO`

`FURTHER_SPECULATIVE_IMPLEMENTATION=NOT_JUSTIFIED`

## Architectural Boundary

This closure does not establish that Matilda's semantic behavior is universally reliable or that future admission failures cannot occur.

It establishes only that the investigated failure does not currently justify another production change.

Existing production boundaries remain authoritative:

- Matilda remains Interpretation Authority.
- Deterministic runtime does not acquire semantic authorship.
- Project-context material remains candidate evidence rather than authority.
- Retrieval origin remains runtime-owned provenance rather than a semantic relevance decision.
- Positional selection preserves runtime-owned identity validation.
- Fail-closed validation remains intact.
- No deterministic post-model semantic filtering is introduced.
- No second Ollama invocation is introduced.
- The one-message / one-workflow / one-Ollama-invocation / one-IEL-entry / one-conversation-turn / one-Living-Draft-update invariant remains unchanged.

## Anti-Speculation Boundary

Historical failures alone do not justify reopening closed production contracts.

A future implementation hypothesis in this area requires a distinct current reproduced failure under the active production architecture.

Absent such evidence, do not:

- add additional operation synonyms merely to expand lexical coverage;
- add additional sentence patterns as a substitute for established semantic need;
- introduce a new pre-retrieval semantic classifier;
- introduce deterministic post-model semantic filtering;
- reintroduce Hypothesis #2 prior-turn query transport;
- reopen the historical Adaptive Detail mechanism.

This is an evidence boundary, not a claim of universal correctness.

## Failure Containment Record

Hypothesis #2 was activated only after isolated validation and explicit authorization.

Live dogfood did not establish its causal benefit.

The hypothesis was therefore abandoned and fully reverted rather than layered into the production architecture.

The clean exact-commit runtime was rebuilt and restored before the parent investigation continued.

This preserves the repository's rollback, recovery, failure-containment, and anti-speculation doctrine.

## Accidental Commit Recovery

During closure work, an accidental commit captured unrelated pre-existing local artifacts.

That commit was not retained.

The active branch was safely reset to the verified baseline while preserving the pre-existing worktree artifacts locally.

The remote branch was repaired using a bounded force-with-lease operation.

Post-recovery verification established:

- local HEAD: `d89b9119bca6d5d105057942bc83804898e652bc`
- remote HEAD: `d89b9119bca6d5d105057942bc83804898e652bc`
- local/remote divergence: `0 0`
- unrelated local worktree artifacts preserved.

The accidental commit is not part of the active branch lineage.

## Runtime Closure State

The clean exact-commit Matilda backend was restored and verified healthy.

Observed closure state:

`ACTIVE_BASELINE=d89b9119bca6d5d105057942bc83804898e652bc`

`HYPOTHESIS_2_SOURCE_PRESENT=NO`

`HYPOTHESIS_2_RUNTIME_PRESENT=NO`

`UI_HTTP=200`

## DR Disposition

This investigation warrants a closure DR because it contains:

- a committed supported hypothesis;
- a live-tested but non-causal hypothesis that was reverted;
- successor-contract validation;
- exact-baseline runtime restoration;
- an accidental-commit recovery;
- and a durable anti-speculation boundary governing future work.

The closure document itself does not claim that a new DR snapshot has already been completed.

`CLOSURE_DR_REQUIRED=YES`

`CLOSURE_DR_COMPLETED=NO`

A canonical repository DR checkpoint should be performed after this closure record is committed and pushed, using the established DR pipeline and without absorbing unrelated worktree artifacts.

## Final State

`MATILDA_ADMISSION_GENERALIZATION_INVESTIGATION=CLOSED`

`HYPOTHESIS_1=RESOLVED`

`HYPOTHESIS_2=ABANDONED_NON_CAUSAL_AND_REMOVED`

`HYPOTHESIS_3=CLOSED_NO_CURRENT_FAILURE`

`DISTINCT_REMAINING_REPRODUCED_FAILURE=NONE`

`ADDITIONAL_IMPLEMENTATION_JUSTIFIED=NO`

`CURRENT_STABLE_PRODUCTION_CONTRACTS=PRESERVE`

`FUTURE_REOPEN_CONDITION=DISTINCT_CURRENT_REPRODUCED_FAILURE`

`NEXT_ACTION=COMMIT_CLOSURE_RECORD_THEN_RUN_CANONICAL_DR_CHECKPOINT`
