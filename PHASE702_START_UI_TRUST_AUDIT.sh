#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

REPORT="docs/phase702-ui-trust-audit.md"

{
  echo "# Phase 702 UI Trust & Clarity Audit"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Scope"
  echo
  echo "- Verify Matilda chat behavior truthfully."
  echo "- Identify UI surfaces that may imply capabilities not currently wired."
  echo "- Do not mutate execution, persistence, database schema, SSE routes, workers, or backend behavior."
  echo
  echo "## Chat / Matilda Search Results"
  echo
  echo '```'
  grep -RInE "Matilda|/api/chat|api/chat|stub|placeholder|deterministic|fallback|ollama|chat" \
    app server components lib pages src 2>/dev/null || true
  echo '```'
  echo
  echo "## KPI / Ambiguous State Search Results"
  echo
  echo '```'
  grep -RInE "\"--\"|'--'|Critical|offline|degraded|unknown|N/A|Loading|stub" \
    app server components lib pages src 2>/dev/null || true
  echo '```'
  echo
  echo "## Phase 702 Initial Finding"
  echo
  echo "This audit is intentionally read-only. It establishes the first Phase 702 checkpoint before UI trust labels or clarity patches are applied."
  echo
  echo "## Next Patch Target"
  echo
  echo "Use this report to patch only UI truth-alignment surfaces:"
  echo
  echo "1. Matilda chat status labeling."
  echo "2. KPI placeholder replacement."
  echo "3. Health status explanation."
  echo "4. Agent/subsystem reasoning text."
} > "$REPORT"

chmod +x PHASE702_START_UI_TRUST_AUDIT.sh

git add PHASE702_START_UI_TRUST_AUDIT.sh docs/phase702-ui-trust-audit.md
git commit -m "Phase 702: start UI trust audit"
git push
