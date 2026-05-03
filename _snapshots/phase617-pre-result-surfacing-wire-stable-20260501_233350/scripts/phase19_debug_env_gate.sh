set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

perl -0777 -i -pe '
  if ($_ !~ /\[phase19\]\s+env/) {
    s/(const\s+app\s*=\s*express\(\)\s*;\s*\n\s*registerOrchestratorStateRoute\(app\)\s*;\s*\n)/
$1if (process.env.PHASE19_DEBUG === "1") {\n  console.log("[phase19] env", {\n    PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,\n    PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,\n  });\n}\n/s;
  }
' server.mjs

perl -0777 -i -pe '
  if ($_ !~ /PHASE19_DEBUG/) {
    s/return res\.status\(404\)\.json\(\{\s*ok:\s*false,\s*error:\s*"not_found"\s*\}\);/
if (process.env.PHASE19_DEBUG === "1") {\n      return res.status(404).json({ ok: false, error: "not_found", debug: { PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE } });\n    }\n    return res.status(404).json({ ok: false, error: "not_found" });/s;
  }
' server/orchestrator_state_route.mjs

echo "=== Grep: phase19 debug markers ==="
rg -n "\\[phase19\\] env|PHASE19_DEBUG" server.mjs server/orchestrator_state_route.mjs
