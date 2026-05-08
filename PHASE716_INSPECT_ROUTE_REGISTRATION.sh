
#!/bin/bash

set -u

OUT="phase716_route_registration_inspection.txt"

: > "$OUT"

{

  printf '%s\n' "===== PHASE 716 ROUTE REGISTRATION INSPECTION ====="

  printf '\n%s\n' "[1] Branch + status"

  git branch --show-current

  git status --short

  printf '\n%s\n' "[2] Route index"

  sed -n '1,240p' server/routes/index.js || true

  printf '\n%s\n' "[3] Bootstrap route registration"

  sed -n '1,240p' server/bootstrap/register-routes.js || true

  printf '\n%s\n' "[4] Existing run_view route"

  sed -n '1,240p' server/routes/phase36_run_view.mjs || true

  printf '\n%s\n' "[5] Existing task API route"

  sed -n '1,320p' server/routes/api-tasks-postgres.mjs || true

  printf '\n%s\n' "[6] Execution inspector test UI"

  sed -n '1,220p' app/dev/page-ExecutionInspectorTest.tsx || true

  printf '\n%s\n' "===== PHASE 716 ROUTE REGISTRATION INSPECTION COMPLETE ====="

} | tee "$OUT"

