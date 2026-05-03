# Phase 423.2 — Step 1 Anchor Extraction Procedure

## Purpose

Convert the Phase 423-scoped evidence record into an exact extraction procedure so the five required anchors can be recorded without interpretation drift.

This is still Step 1 only.

No runtime behavior.
No architecture change.
No execution expansion.
Documentation only.

---

## Current State

Step 1 remains OPEN.

What now exists:

- broad discovery scaffolds
- Phase 423 commit scope runner
- Phase 423 evidence record

What is still missing:

The actual five anchors written into the evidence record from commit-scoped inspection.

Those anchors are:

Execution entry file  
Execution handler  
Governance gate  
Activation check  
Approval check  

---

## Deterministic Extraction Rule

Extraction must proceed from the Phase 423 commit scope outward.

Order:

1. identify files touched by 1d45520a and 5dc2be91
2. inspect those files directly
3. identify exported or introduced execution-facing symbols
4. trace only immediate imports and direct calls
5. record the five anchors
6. stop

Do not expand into Step 2.
Do not draw safety conclusions.

---

## Exact Terminal Procedure

Run these in order.

### 1. File list

git show --name-only --format=oneline 1d45520a
git show --name-only --format=oneline 5dc2be91

Goal:

List only the files directly touched in the execution introduction corridor.

---

### 2. Patch symbol extraction

git show 1d45520a | grep -E "^\+.*(export|function|const|class|type|interface|execute|execution|proof|attempt|gate|activat|approv|authoriz|runtime|boundary)" || true
git show 5dc2be91 | grep -E "^\+.*(export|function|const|class|type|interface|execute|execution|proof|attempt|gate|activat|approv|authoriz|runtime|boundary)" || true

Goal:

Reveal newly introduced symbols likely to define the proof execution chain.

---

### 3. Direct file inspection

For every file surfaced by the two commit listings, inspect:

sed -n '1,260p' <file-path>

If needed:

sed -n '261,520p' <file-path>

Goal:

Locate direct entrypoint and direct downstream calls.

---

### 4. Immediate import tracing

For any candidate file, inspect imports and immediately imported local files only.

Do not expand beyond one hop unless the direct call chain requires it.

Goal:

Prevent broad scan drift while still allowing direct topology confirmation.

---

## Recording Criteria For Each Anchor

### Execution entry file

Record only if the file contains the first explicit proof-execution-facing entry into the governed execution path.

Must be a direct file, not an inferred one.

### Execution handler

Record only if the symbol performs or initiates the bounded execution attempt.

### Governance gate

Record only if the symbol explicitly gates or authorizes downstream execution in the same path.

### Activation check

Record only if the symbol explicitly verifies activation state or equivalent execution-on condition in the same path.

### Approval check

Record only if the symbol explicitly verifies operator approval or an equivalent approval requirement in the same path.

---

## Disallowed Recording

Do not record a symbol merely because it is governance-related.

Do not record:

- general governance cognition packaging
- archive packaging
- proof harness wrappers
- selector-only surfaces
- type-only surfaces
- unrelated governance reporting surfaces

If uncertain, leave blank and continue inspecting commit-scoped files.

UNCERTAIN evidence does not close Step 1.

---

## Direct Output Format

When anchors are found, record them in this exact shape:

Execution entry file:
<path>

Execution handler:
<path>::<symbol>

Governance gate:
<path>::<symbol>

Activation check:
<path>::<symbol>

Approval check:
<path>::<symbol>

---

## Step 1 Closure Rule

Step 1 closes only when:

- all five anchors are explicitly recorded
- each anchor comes from Phase 423-scoped evidence
- direct topology is confirmed
- no anchor is inferred from unrelated governance surface noise

Until then:

Step 1 remains OPEN
Step 2 remains BLOCKED

---

## Immediate Next Action

Populate the existing evidence record using this procedure.

No additional documentation corridor should open until the five anchors are recorded.

