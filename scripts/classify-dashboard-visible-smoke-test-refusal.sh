#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
OUT="docs/checkpoints/MATILDA_UI_503_DASHBOARD_VISIBLE_SMOKE_TEST_REFUSED_CONNECTION.md"

cat > "$OUT" << 'DOC'
# Matilda UI 503 — Dashboard Visible Smoke Test Connection Refusal

Issue resolved: NO

Observed result:
- The browser returned `ERR_CONNECTION_REFUSED` at `http://127.0.0.1:5173/`.
- The Matilda request was NOT submitted.
- No visible Matilda response was produced.
- The authorized dashboard submission was NOT consumed.
- No additional diagnostic Ollama invocation occurred.

Classification:
- DASHBOARD_VISIBLE_SMOKE_TEST_REACHED_MATILDA=NO
- FAILURE_CLASS=FRONTEND_RUNTIME_REACHABILITY
- MATILDA_503_REPRODUCED=NO
- SUPPORT_REFERENCE_FIX_DISPROVEN=NO
- ISSUE_RESOLVED=NO

Next evidence required:
- Inspect the actual frontend process and listener state.
- Determine why the earlier readiness check reported port 5173 ready although the browser could not connect.
- Do not retry the dashboard submission until frontend reachability is established.
DOC

printf '\n=== PROCESS / LISTENER EVIDENCE ===\n'
printf '%s\n' '--- 5173 listener ---'
lsof -nP -iTCP:5173 -sTCP:LISTEN || true

printf '%s\n' '--- frontend-related processes ---'
pgrep -af 'vite|node.*vite' || true

printf '%s\n' '--- frontend smoke log ---'
tail -120 /tmp/matilda-smoke-frontend.log 2>/dev/null || echo 'NO_FRONTEND_SMOKE_LOG'

printf '%s\n' '--- backend listener ---'
lsof -nP -iTCP:3000 -sTCP:LISTEN || true

printf '%s\n' '--- direct frontend HTTP probe ---'
curl -sS -D - --max-time 5 http://127.0.0.1:5173/ -o /tmp/matilda-frontend-probe-body.txt || true

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'NEW_DASHBOARD_SUBMISSION=NO' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'AUTHORIZED_VISIBLE_SUBMISSION_CONSUMED=NO' \
  'NEXT_ACTION=CLASSIFY_FRONTEND_REACHABILITY_BEFORE_ANY_RETRY'

git add -- "$OUT" scripts/classify-dashboard-visible-smoke-test-refusal.sh
git commit -m "Classify Matilda dashboard connection refusal"
git push
