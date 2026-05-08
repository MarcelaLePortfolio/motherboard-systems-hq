
#!/bin/bash

set -u

OUT="phase716_execution_inspector_component_inspection.txt"

: > "$OUT"

{

  printf '%s\n' "===== PHASE 716 EXECUTION INSPECTOR COMPONENT INSPECTION ====="

  printf '\n%s\n' "[1] Branch + status"

  git branch --show-current

  git status --short

  printf '\n%s\n' "[2] Locate ExecutionInspector component"

  find app -type f | grep -Ei 'ExecutionInspector|Inspector|Task|Guidance' | sort || true

  printf '\n%s\n' "[3] Read ExecutionInspector component"

  sed -n '1,260p' app/components/ExecutionInspector.tsx || true

  printf '\n%s\n' "[4] Locate component usage"

  grep -Rni "ExecutionInspector" app 2>/dev/null || true

  printf '\n%s\n' "[5] Probe run evidence endpoint"

  curl -sS -i "http://localhost:3000/api/runs?limit=10" | head -80 || true

  printf '\n%s\n' "[6] Probe run detail from known task response run_id"

  curl -sS -i "http://localhost:3000/api/runs/run_8d705078-6853-44cb-92c4-94bae960c8ea" | head -100 || true

  printf '\n%s\n' "===== PHASE 716 EXECUTION INSPECTOR COMPONENT INSPECTION COMPLETE ====="

} | tee "$OUT"

