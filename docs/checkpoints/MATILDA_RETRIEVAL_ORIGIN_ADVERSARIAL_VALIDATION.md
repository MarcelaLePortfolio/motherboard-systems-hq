# Matilda Retrieval-Origin Adversarial Validation

## Status

VALIDATION COMPLETE — PRODUCTION ADOPTION NOT AUTHORIZED

## Objective

Determine whether presenting runtime-derived retrieval origin to Matilda causes her to over-select a structurally discovered candidate merely because it is labeled `structural`.

This validation specifically addresses the confound created by the earlier Packages retrieval-origin experiment, where the only structurally discovered candidate was also the correct semantic target.

## Architectural Boundary

The experiment preserves the established separation between:

1. Retrieval — runtime determines which candidates are supplied.
2. Semantic admission — Matilda determines which supplied candidates materially affect the immediate reply.
3. Identity transport — Matilda returns invocation-local candidate positions and runtime validates and resolves them.

Retrieval origin is treated only as runtime-derived provenance describing how a candidate entered the supplied universe.

It does not grant semantic authority to runtime and does not mean a candidate is relevant.

## Prior Packages Result

A prior 30-run validation-only Packages experiment compared retrieval-origin presentation against the existing unlabeled positional control.

Existing unlabeled original-11 control:

- Accepted: 30/30
- Fail-closed: 0/30
- Navigation selected: 16/30
- CSS selected: 22/30
- Sidebar documentation selected: 1/30

Retrieval-origin presentation:

- Accepted: 30/30
- Fail-closed: 0/30
- Navigation selected: 30/30
- CSS selected: 0/30
- Sidebar documentation selected: 0/30

This was strongly promising but confounded because exactly one candidate was marked `structural`, and that candidate was the correct Navigation target.

Therefore the result could not by itself establish that Matilda was using retrieval origin as neutral provenance rather than treating `structural` as a relevance cue.

## Adversarial Fixture Design

A bounded temporary fixture was constructed and validated offline using the real repository retrieval implementation.

The successful fixture used the natural request:

> How does the status workspace become active?

The material lexical candidate contained the actual runtime decision:

`activeWorkspace === "status"`

The structurally discovered candidate was a supporting `ModeKind` type declaration.

The fixture intentionally established:

- a genuinely material lexical runtime candidate,
- a structurally discovered supporting candidate,
- the structural candidate was not required to answer the runtime-behavior question,
- structural provenance was produced by the real bounded retrieval mechanism,
- no arbitrary candidate was manually labeled structural,
- candidate inclusion and ordering remained runtime-derived.

Offline validation established:

- Retrieval executed successfully.
- `status` remained an exact query term.
- Material `StatusWorkspace.tsx` was inside the lexical runtime top three.
- `ModeKind.ts` entered through structural excerpt slot 3.
- Exactly one structural child candidate was produced.
- No live-model call was used during fixture validation.

## Live Adversarial Experiment

Two arms used the same fixture, same candidate universe, same candidate order, and same positional selection identity.

Generation policy:

- Unseeded
- 30 runs per arm
- 60 total live calls
- One Ollama invocation per run
- No retries
- Position-only semantic-selection identity
- Matilda remained semantic-selection authority

### Arm A — Unlabeled Positional Control

Results:

- Accepted: 30/30
- Fail-closed: 0/30
- Material lexical candidate selected: 30/30
- Immaterial structural candidate selected: 0/30
- Both selected: 0/30
- Neither selected: 0/30
- Empty selection: 0/30

### Arm B — Retrieval-Origin Presentation

Results:

- Accepted: 30/30
- Fail-closed: 0/30
- Material lexical candidate selected: 29/30
- Immaterial structural candidate selected: 0/30
- Both selected: 0/30
- Neither material nor structural selected: 1/30
- Empty selection: 0/30

The structurally discovered `ModeKind` candidate was never selected in either arm.

## Determination

The adversarial control materially deconfounds the earlier Packages result.

The evidence does not support the hypothesis that Matilda blindly selects a candidate merely because it is presented as `structural`.

On the tested adversarial fixture:

- Matilda ignored the semantically immaterial structural candidate 30/30 times when retrieval origin was visible.
- Matilda continued selecting the genuinely material lexical candidate 29/30 times.
- Retrieval-origin presentation caused no structural identity validation failures.
- All 60 responses were accepted.
- Fail-closed count remained zero.

Combined with the earlier Packages result, the evidence supports the narrower determination:

**Runtime-derived retrieval-origin provenance is a promising presentation signal that may improve Matilda's attention to structurally discovered evidence without itself replacing Matilda's semantic-selection authority.**

## Boundaries

This validation does NOT establish that:

- semantic admission is globally reliable,
- retrieval-origin presentation is production-ready,
- every structural candidate will be handled correctly,
- retrieval origin should be used for deterministic filtering,
- structural candidates should be preferred, reordered, or automatically selected,
- lexical candidates should be suppressed,
- candidate inclusion rules should change,
- production positional selection is already adopted.

The retrieval-origin treatment produced one run in which the material candidate was not selected, so semantic admission remains stochastic rather than universally solved.

## Production Constraint

Any future production design must preserve retrieval origin as runtime-owned provenance from candidate construction through model presentation.

It must not infer structural origin later from a hard-coded path/range fixture rule.

A compliant production design must also preserve:

- Matilda as semantic-selection authority,
- deterministic candidate ordering,
- runtime-only structural membership validation,
- no post-model semantic filtering,
- no second Ollama invocation,
- fail-closed malformed/out-of-range selection handling,
- separation between semantic admission and support provenance,
- ephemeral/nonpersistent semantic-selection metadata unless separately authorized.

## Current Disposition

Adversarial retrieval-origin validation corridor: CLOSED.

Result:

`RETRIEVAL_ORIGIN_UNIQUE_MARKER_CONFOUND_MATERIALLY_DECONFOUNDED`

Production adoption: NOT AUTHORIZED.

Production source implementation: NOT AUTHORIZED.

Commit: NOT AUTHORIZED.

Push: NOT AUTHORIZED.

Next appropriate corridor:

Offline production-contract design for preserving runtime-derived `lexical | structural` provenance through candidate construction and positional semantic-selection presentation without changing semantic authority or candidate inclusion.
