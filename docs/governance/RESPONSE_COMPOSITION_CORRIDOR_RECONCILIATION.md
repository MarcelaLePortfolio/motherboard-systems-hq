# Response Composition Corridor Reconciliation

## Status

Repository evidence now supports revising the original Response Composition corridor map.

The original corridors were:

1. Summary Composition
2. Reasoning Classification
3. Evidence Composition
4. Boundary Composition
5. Adaptive Detail Selection

The investigation demonstrated that several responsibilities originally grouped under Reasoning Classification and Evidence Composition now separate naturally into deterministic runtime concerns and semantic composition concerns.

## Corridor Determinations

### 1. Summary Composition

**Status:** IMPLEMENTED_AND_VALIDATED

Verified repository evidence includes:

- explicit Summary Composition prompt instructions;
- dedicated Summary Composition tests;
- response-contract guard coverage;
- preservation of the one-model-invocation architecture.

Summary Composition is closed.

---

### 2. Reasoning Classification

**Status:** NEEDS_RESCOPE

The original corridor combined responsibilities that no longer belong together.

The repository now distinguishes:

#### Deterministic concern

**Evidence Sufficiency**

This determines whether validated supporting provenance exists.

It must not depend on later interpretation of arbitrary prose.

#### Semantic concern

**Reasoning Composition**

This concerns how Matilda presents a grounded explanation to the user.

These responsibilities should not remain collapsed into one Reasoning Classification corridor.

The existing `explanationStatus` field is infrastructure relevant to disclosure behavior, but its existence alone does not establish completion of the original Reasoning Classification corridor.

---

### 3. Evidence Composition

**Status:** ARCHITECTURE_RESOLVED_IMPLEMENTATION_INCOMPLETE

The repository now contains support-provenance infrastructure:

- `supportSourceReferences`
- stable conversation-source identity
- bounded project-context source identity
- structural fail-closed validation
- dedicated support-reference tests

This infrastructure answers:

> Which supplied sources are identified as support?

It does **not** yet answer:

> How should validated evidence be composed into the user-facing response?

Evidence Provenance and Evidence Composition are therefore distinct.

Evidence Composition remains open.

---

### 4. Boundary Composition

**Status:** IMPLEMENTED_BUT_NOT_FULLY_VALIDATED

Relevant behavior already exists in the response contract, including instructions to:

- preserve material uncertainty
- preserve scope boundaries
- preserve evidence distinctions
- avoid strengthening supplied evidence
- avoid claiming certainty where evidence does not support it
- preserve implementation boundaries

However, repository evidence does not yet establish a dedicated Boundary Composition behavioral-validation corridor.

Boundary Composition must therefore not be marked closed solely because related prompt constraints exist.

---

### 5. Adaptive Detail Selection

**Status:** IMPLEMENTED_BUT_NOT_FULLY_VALIDATED

Relevant behavior exists through:

- conclusion-first Summary Composition
- instructions to include only supporting detail needed for the current interaction
- `explanationStatus`
- explicit explanation-request behavior

However, repository evidence does not yet establish a complete, dedicated Adaptive Detail Selection capability or behavioral-validation suite.

Adaptive Detail Selection remains open.

## Revised Response Composition Map

Response Composition

- Summary Composition — CLOSED
- Evidence Sufficiency — deterministic runtime concern
- Reasoning Composition — semantic composition concern
- Evidence Composition — semantic composition concern
- Boundary Composition — partially implemented; validation incomplete
- Adaptive Detail Selection — partially implemented; validation incomplete

## Architectural Distinction

Deterministic runtime responsibilities remain separate from semantic composition responsibilities.

### Deterministic runtime

Responsible for:

- context eligibility
- provenance validation
- evidence sufficiency
- fail-closed enforcement

### Semantic composition

Responsible for:

- natural-language reasoning
- evidence presentation
- boundary communication
- response detail selection

This separation preserves:

- one user message → one workflow → one Ollama invocation
- Matilda as Interpretation Authority
- workflow ownership of deterministic validation
- no second semantic author
- no hidden chain-of-thought persistence

## Current Next Corridor

The active implementation work remains:

**Support Provenance Semantic Production**

Specifically:

1. Instruct the existing Ollama invocation to populate `supportSourceReferences`.
2. Validate returned references against the exact sources supplied to that invocation.
3. Establish the deterministic Evidence Sufficiency result from validated provenance.
4. Only then proceed to semantic Reasoning Composition and Evidence Composition.

## Closure Rule

A Response Composition corridor may be marked complete only when:

- architectural ownership is resolved;
- required runtime behavior is implemented;
- dedicated validation demonstrates the intended behavior; and
- architectural invariants remain preserved.

Architectural resolution alone does not constitute corridor completion.
