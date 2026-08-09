#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — ALTERNATIVE VALIDATION METHOD ==="

echo
echo "=== CURRENT CHECKPOINT ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== REVERT CONFIRMATION ==="
git show --stat --oneline ce335cb5

echo
echo "=== EXISTING BOUNDARY READINESS ==="
cat scripts/document-boundary-composition-behavioral-validation-readiness.sh

echo
echo "=== CURRENT RESPONSE CONTRACT ==="
sed -n '500,545p' scripts/utils/ollamaChat.ts

echo
echo "=== INVESTIGATION ==="
cat <<'QUESTION'
The regex-based Boundary Composition behavioral validation hypothesis was
abandoned after three consecutive harness failures and reverted.

Do not retry regex matching.

Investigate a different validation class that preserves the stable runtime.

Known evidence from the abandoned runs:

1. Material scope replies preserved the downstream-validation boundary.
2. Material uncertainty replies preserved the absence of independent runtime
   validation.
3. Failures were caused by lexical assertions rejecting semantically equivalent
   wording.
4. Production support-provenance fail-closed behavior was correct and must not
   be weakened.

Determine whether the next behavioral-validation method should use a bounded
human-readable evidence ledger rather than pass/fail lexical assertions.

A valid alternative method must:

- execute each scenario independently;
- capture the exact user message;
- capture the exact supplied project-context excerpt;
- capture the exact Matilda reply;
- capture supportSourceReferences;
- capture evidenceSufficient;
- capture evidence artifact;
- record invocation success/failure;
- make NO automated semantic judgment about whether wording preserved the
  boundary;
- make NO second model invocation;
- leave production runtime untouched;
- permit repository-evidence-based collaborative review of each output;
- distinguish harness/runtime failures from semantic observations;
- avoid silently declaring Boundary Composition validated.

Evaluate five scenario classes:

A. material scope boundary;
B. material unresolved uncertainty;
C. authorization boundary;
D. unsupported capability boundary;
E. immaterial boundary.

Return exactly one classification:

BOUNDARY_COMPOSITION_EVIDENCE_LEDGER_VALIDATION_READY
BOUNDARY_COMPOSITION_ALTERNATIVE_VALIDATION_NOT_READY

Then identify exactly one smallest next unit.

Do not implement runtime changes.
Do not add Boundary Status or Boundary artifact.
Do not begin Adaptive Detail Selection.
QUESTION

echo
echo "=== DETERMINATION TEMPLATE ==="
cat <<'DETERMINATION'
Candidate alternative:

A deterministic live evidence-capture harness may be appropriate if repository
inspection confirms that semantic success should be reviewed from captured
outputs rather than encoded as brittle lexical assertions.

The harness itself must not claim validation success.
DETERMINATION
