
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "=== Patch route to prove handler is mounted + fix gate debug detection ==="

perl -0777 -i -pe '
  if ($_ !~ m{/orchestrator/state\._debug}) {
    s/app\.get\("\/orchestrator\/state",\s*\(req,\s*res\)\s*=>\s*\{\n/app.get("\/orchestrator\/state", (req, res) => {\n/s;

    # Insert debug route immediately before /orchestrator/state definition (after app validation)
    s/(export function registerOrchestratorStateRoute\(app\)\s*\{\n\s*if\s*\(!app\s*\|\|\s*typeof app\.get\s*!==\s*"function"\)\s*\{\n\s*throw new Error\([^\n]*\);\n\s*\}\n\n)/$1  // Phase 19 debug: confirm route module is loaded + env visible (only when PHASE19_DEBUG=1)\n  app.get(\"\\/orchestrator\\/state._debug\", (req, res) => {\n    if (process.env.PHASE19_DEBUG !== \"1\") {\n      return res.status(404).json({ ok: false, error: \"not_found\" });\n    }\n    return res.status(200).json({\n      ok: true,\n      ts: Date.now(),\n      env: {\n        PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,\n        PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,\n        PHASE19_DEBUG: process.env.PHASE19_DEBUG,\n      },\n      note: \"If you can see this, the module is mounted on the running server.\",\n    });\n  });\n\n/s;
  }
' server/orchestrator_state_route.mjs
perl -0777 -i -pe '
  # Replace the first gate block inside /orchestrator/state with a more explicit version.
  s/if\s*\(!truthy\(process\.env\.PHASE19_ENABLE_ORCH_STATE\)\)\s*\{\s*(?:.|\n)*?\}\n\s*const enabled/if (!truthy(process.env.PHASE19_ENABLE_ORCH_STATE)) {\n      if (process.env.PHASE19_DEBUG === \"1\") {\n        return res.status(404).json({\n          ok: false,\n          error: \"not_found\",\n          debug: {\n            PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,\n            PHASE19_DEBUG: process.env.PHASE19_DEBUG,\n          },\n        });\n      }\n      return res.status(404).json({ ok: false, error: \"not_found\" });\n    }\n\n    const enabled/s;
' server/orchestrator_state_route.mjs

echo "=== Grep: debug route + gate ==="
rg -n "state\\._debug|PHASE19_DEBUG|PHASE19_ENABLE_ORCH_STATE|/orchestrator/state" server/orchestrator_state_route.mjs
