#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
OUT="docs/phase464_x_system_health_route_candidates.txt"

CANDIDATES=(
  "routes/diagnostics/systemHealth.ts"
  "routes/diagnostics/systemHealth.js"
  "routes/routes/diagnostics/systemHealth.ts"
  "routes/routes/diagnostics/systemHealth.js"
  "routes_backup/diagnostics/systemHealth.ts"
  "routes_backup/diagnostics/systemHealth.js"
)

{
  echo "PHASE 464.X — SYSTEM HEALTH ROUTE CANDIDATES"
  echo "============================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "CONTEXT"
  echo "- Browser-side false positives eliminated:"
  echo "  * public/js/dashboard-status.js"
  echo "  * public/js/phase457_restore_task_panels.js"
  echo "  * public/js/phase457_neutralize_legacy_observational_consumers.js"
  echo "- Phase456 shortlist points back to authoritative system health route files."
  echo

  for f in "${CANDIDATES[@]}"; do
    if [ -f "$f" ]; then
      echo "FILE: $f"
      echo "----------------------------------------"
      rg -n 'SYSTEM_HEALTH|systemHealth|status: "OK"|situationSummary|summary|guidance|operator|No active tasks|Awaiting operator input|res\.json|res\.send|router\.get|express\.Router' "$f" || true
      echo
      sed -n '1,220p' "$f"
      echo
    fi
  done

  echo "DECISION GATE"
  echo "- Choose the first existing route file that actually assembles health/guidance payload text."
  echo "- Next step after this artifact: mutate ONE authoritative systemHealth route file only."
} > "$OUT"

echo "Wrote $OUT"
