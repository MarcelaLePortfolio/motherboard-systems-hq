#!/usr/bin/env bash
set -euo pipefail

echo "=== SUPPORT SOURCE REFERENCE CONTRACT — COMPATIBILITY REVIEW ==="

cat <<'QUESTION'
The proposed contract has been designed.

This investigation is NOT about redesigning it.

Determine whether the proposed contract is compatible with the existing
Conversation Engine architecture.

Architectural invariants to evaluate:

1. One user message
   ->
   one workflow
   ->
   one Ollama invocation

2. Matilda remains the sole semantic author.

3. Workflow owns deterministic validation.

4. Durable Interpretation remains independent.

5. Explanation requests remain ordinary follow-up turns.

6. IEL persists semantic artifacts rather than generating them.

7. No hidden reasoning or chain-of-thought is stored.

8. Existing response contract can evolve without invalidating
   previous architectural boundaries.

For each invariant answer:

- Preserved
- Violated
- Requires refinement

Then determine:

Does supportSourceReferences introduce:

- a new semantic subsystem?
- a second semantic author?
- a second model invocation?
- a new architectural boundary?

If every invariant is preserved, classify:

ARCHITECTURALLY COMPATIBLE

Otherwise classify:

BLOCKED

Do not redesign the contract.
Do not implement the contract.
Only determine architectural compatibility.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
