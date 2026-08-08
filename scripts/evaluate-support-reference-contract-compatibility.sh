#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SUPPORT SOURCE REFERENCE CONTRACT — COMPATIBILITY EVALUATION ==="

echo
cat <<'ASSESSMENT'
Architectural invariant review

1. One user message
   -> one workflow
   -> one Ollama invocation

Result:
PRESERVED

2. Matilda remains the sole semantic author.

Result:
PRESERVED

3. Workflow owns deterministic validation.

Result:
PRESERVED

4. Durable Interpretation remains independent.

Result:
PRESERVED

5. Explanation requests remain ordinary follow-up turns.

Result:
PRESERVED

6. IEL persists semantic artifacts rather than generating them.

Result:
PRESERVED

7. No hidden reasoning or chain-of-thought is introduced.

Result:
PRESERVED

8. Response contract evolves without creating a new architectural boundary.

Result:
PRESERVED

Architectural impact

supportSourceReferences:

✓ extends the existing structured response
✓ preserves the existing Conversation Engine
✓ preserves one Ollama invocation
✓ preserves Interpretation Authority
✓ preserves workflow validation ownership
✓ introduces provenance metadata only
✓ does not introduce another semantic author
✓ does not introduce another model invocation
✓ does not introduce another runtime

FINAL CLASSIFICATION

ARCHITECTURALLY COMPATIBLE

The architectural investigation corridor is complete.

The next canonical corridor is:

Response Contract Extension — Implementation
ASSESSMENT

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
