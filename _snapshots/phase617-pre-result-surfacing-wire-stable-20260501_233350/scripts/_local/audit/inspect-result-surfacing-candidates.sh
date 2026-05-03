#!/bin/bash
set -e

echo "🔍 Inspecting result surfacing candidates for Phase 617..."

echo ""
echo "=== RESPONSE COMPILER CONTRACT DOC ==="
sed -n '1,90p' PHASE604_COMMUNICATION_CONTRACT_DEFINITION.txt || true

echo ""
echo "=== RESPONSE COMPILER ISOLATED TEST OUTPUT ==="
sed -n '1,90p' PHASE607_RESPONSE_COMPILER_ISOLATED_TEST.txt || true

echo ""
echo "=== PASSIVE VERIFY RESULT SHAPE ==="
sed -n '1,100p' PHASE608_RESPONSE_COMPILER_PASSIVE_VERIFY.txt || true

echo ""
echo "=== ACTIVE PASSIVE RESULT NOTES ==="
sed -n '1,80p' PHASE608_RESPONSE_COMPILER_PASSIVE_ACTIVE.txt || true

echo ""
echo "=== TRIGGER VERIFICATION OUTPUT PREVIEWS ==="
sed -n '1,80p' PHASE614_TRIGGER_URL_FIX_VERIFICATION.txt || true

echo ""
echo "=== SEARCH: output_preview / explanation_preview / systemTrace ==="
grep -RIn "outcome_preview\|explanation_preview\|systemTrace\|response compiler\|Response Compiler" server app lib src scripts . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "=== SEARCH: Execution Inspector files ==="
find app public src server -type f 2>/dev/null | grep -Ei "inspector|execution|task|telemetry" || true

echo ""
echo "=== SEARCH: API task read paths ==="
grep -RIn "SELECT .*tasks\|FROM tasks\|/api/.*task\|recent.*task\|task_events" server app src . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "✅ Candidate inspection complete. Next patch should surface existing outcome_preview/Tier 1 first, then explanation_preview/Tier 2 if already present."
