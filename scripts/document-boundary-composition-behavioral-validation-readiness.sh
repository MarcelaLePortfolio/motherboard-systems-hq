#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — BEHAVIORAL VALIDATION READINESS ==="

cat <<'FINDINGS'
BOUNDARY_COMPOSITION_BEHAVIORAL_VALIDATION_READY

Repository-supported findings:

1. Boundary Composition is already partially represented in the existing
   semantic reply contract.

2. Summary Composition explicitly requires:
   "Preserve material uncertainty, scope boundaries, and evidence distinctions
   when they affect the conclusion."

3. Reasoning Composition explicitly requires material uncertainty or unresolved
   limits when they affect the strength or applicability of a conclusion.

4. Reasoning Composition also grounds explanations in:
   - established evidence;
   - architectural constraints;
   - tradeoffs;
   - implementation boundaries;
   - material uncertainty.

5. The current reply contract independently forbids strengthening or broadening
   supplied evidence and forbids claiming qualities that were not actually
   tested.

6. Therefore several important Boundary Composition behaviors already exist at
   the prompt-contract level.

7. Some boundary-relevant runtime state is already structured:
   - explanationStatus;
   - evidenceSufficient;
   - priorExplanationEvidenceStatus;
   - explicitEvidenceRequest.

8. projectContextWarning is supplied as bounded semantic context but is not a
   dedicated response Boundary artifact.

9. durableInterpretation may preserve durable constraints and unresolved
   questions, but it is not a user-facing Boundary Composition artifact and
   must not be repurposed as one.

10. Evidence Composition provides deterministic evidence presentation and
    evidence sufficiency behavior, but it does not own general scope,
    authorization, architectural, deferred-work, or capability boundaries.

11. No dedicated Boundary Status or Boundary artifact currently exists in the
    structured Ollama response contract.

12. Current repository evidence does not establish that a dedicated structured
    Boundary artifact is necessary.

13. Adding such an artifact before behavioral validation would risk duplicating
    semantics already represented by the reply contract and existing structured
    state.

14. Boundary Composition can remain inside the existing single semantic
    invocation. No repository evidence currently justifies a second model call.

15. The remaining gap is behavioral evidence:
    the repository establishes instructions for preserving material boundaries,
    but does not yet demonstrate through bounded behavioral validation that
    Matilda reliably:
    - surfaces a material scope boundary when it changes the conclusion;
    - surfaces unresolved uncertainty when it changes applicability;
    - preserves an authorization limit when implementation is otherwise ready;
    - avoids unsupported capability claims;
    - omits immaterial boundaries rather than producing disclaimer inventories.

16. Therefore the smallest safe next unit is behavioral validation only.

17. Behavioral validation must precede any decision to introduce:
    - a deterministic Boundary signal;
    - a structured Boundary artifact;
    - additional response fields;
    - new runtime ownership.

18. This investigation does not authorize implementation.

19. Evidence Composition remains closed.

20. Adaptive Detail Selection has not begun.

Classification:

BOUNDARY_COMPOSITION_BEHAVIORAL_VALIDATION_READY

Smallest next unit:

BOUNDARY_COMPOSITION_BEHAVIORAL_VALIDATION

The next unit should construct bounded structural and live scenarios against the
existing reply contract before modifying runtime behavior.

Required scenario classes:

A. Material scope boundary:
   The available context supports a conclusion only inside a bounded scope.
   The reply should preserve that scope because removing it would overstate the
   conclusion.

B. Material unresolved uncertainty:
   The context supports a provisional conclusion but contains unresolved
   uncertainty that changes its strength or applicability.
   The reply should surface that uncertainty.

C. Authorization boundary:
   Architecture or implementation readiness is established but execution is not
   authorized.
   The reply must not collapse readiness into authorization.

D. Unsupported capability boundary:
   Evidence establishes a narrower property than the user asks about.
   The reply must not broaden the evidence into an unsupported capability claim.

E. Immaterial boundary:
   Context contains a limit that does not affect the immediate conclusion.
   The reply should not mechanically surface it.

Validation must preserve:

- Matilda as semantic and Interpretation Authority;
- one user message -> one workflow -> one Ollama invocation;
- independently authored reply and durableInterpretation;
- existing Summary Composition ownership;
- existing Reasoning Composition ownership;
- closed Evidence Composition behavior;
- existing supportSourceReferences semantics;
- existing evidenceSufficient semantics;
- existing Explanation Status semantics.

Do not add a Boundary artifact yet.
Do not add a Boundary Status yet.
Do not add another model invocation.
Do not modify persistence, API, client, Living Draft, Approval, Delegation,
Envelope, or Execution architecture.
Do not begin Adaptive Detail Selection.

Only if behavioral validation exposes a concrete repeatable failure should the
next implementation surface be classified.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "BOUNDARY_COMPOSITION_BEHAVIORAL_VALIDATION_READY"
