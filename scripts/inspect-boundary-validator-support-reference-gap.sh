#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY VALIDATOR SUPPORT-REFERENCE GAP ==="

echo
echo "=== CURRENT BOUNDARY VALIDATOR ==="
cat scripts/validate-boundary-composition-behavior.ts

echo
echo "=== SUPPORT REFERENCE CONTRACT ==="
sed -n '488,505p' scripts/utils/ollamaChat.ts

echo
echo "=== SUPPORT VALIDATION ==="
sed -n '560,650p' scripts/utils/ollamaChat.ts

echo
echo "=== RECENT VALIDATOR COMMIT ==="
git show --stat --oneline 052e0ead

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
The first Boundary Composition behavioral scenario failed before its reply could
be evaluated because Ollama returned a conversation_turn support reference even
though the validator supplied no conversation history.

Determine from repository evidence only:

1. Is this failure inside Boundary Composition behavior, or is it a support-
   provenance harness/input problem that occurs before boundary assertions?

2. Does the current boundary validator supply project-context evidence but no
   eligible conversation source identifier?

3. Does the support contract permit only identifiers actually supplied in the
   invocation, making the fail-closed rejection correct?

4. Would adding a bounded neutral conversation history turn to the validation
   harness change Boundary Composition semantics, or merely provide a valid
   conversation source if the model elects to cite conversation provenance?

5. Is there already precedent in the Evidence Composition live harness for
   supplying one bounded conversation turn specifically to keep provenance
   selection valid?

6. Would modifying production support validation to tolerate invented
   conversation references be unsafe and contrary to the closed Evidence
   Composition contract?

Return exactly one classification:

BOUNDARY_VALIDATOR_PROVENANCE_HARNESS_GAP
BOUNDARY_COMPOSITION_BEHAVIOR_FAILURE
BOUNDARY_VALIDATOR_GAP_NOT_READY

Then identify exactly one smallest next unit.

Do not modify production runtime.
Do not weaken fail-closed support validation.
Do not modify Boundary Composition prompt behavior.
Do not begin Adaptive Detail Selection.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
