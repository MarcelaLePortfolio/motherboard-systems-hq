
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

TAG="v18.1-orchestration-phase18-complete"
BR="feature/phase19-orchestrator-state"

git fetch --tags -q || true
git checkout -B "$BR" "$TAG"

mkdir -p server scripts

cat > server/orchestrator_state_route.mjs <<'JS'
/**
 * Phase 19 — Orchestrator State Route (read-only)
 *
 * Gate: PHASE19_ENABLE_ORCH_STATE === "1"
 * Endpoint: GET /orchestrator/state
 *
 * Best-effort snapshot strategy:
 * - Prefer a stable, intentionally-exported global store if present.
 * - Avoid throwing; always return deterministic JSON.
 */

function truthy(v) {
  return String(v || "").trim() === "1";
}

function pickFirstDefined(...vals) {
  for (const v of vals) if (v !== undefined) return v;
  return undefined;
}

function safeClone(obj) {
  // Avoid circular refs; return a minimal serializable structure.
  try {
    return JSON.parse(JSON.stringify(obj));
  } catch {
    // last resort: stringify via toString-ish
    return { kind: "nonserializable", note: "state could not be JSON-stringified" };
  }
}

function readStateFromGlobals() {
  const g = globalThis;

  // Common candidates (Phase 18 patterns vary across implementations)
  const store =
    pickFirstDefined(
      g.__orchestratorStore,
      g.__orchStore,
      g.__orchestrator?.store,
      g.__orchestrator?.orchestratorStore,
      g.__orchestrator?.stateStore
    );

  // Store snapshot methods (try in safest order)
  if (store) {
    if (typeof store.snapshot === "function") return { ok: true, state: store.snapshot() };
    if (typeof store.getState === "function") return { ok: true, state: store.getState() };
    if (typeof store.toJSON === "function") return { ok: true, state: store.toJSON() };
    if (typeof store === "object") return { ok: true, state: store };
  }

  // Sometimes state is hung off a global orchestrator object
  const orch =
    pickFirstDefined(
      g.__orchestrator,
      g.__orch,
      g.__orchestratorRuntime
    );

  if (orch) {
    if (typeof orch.snapshot === "function") return { ok: true, state: orch.snapshot() };
    if (typeof orch.getState === "function") return { ok: true, state: orch.getState() };
    if (typeof orch.state === "object") return { ok: true, state: orch.state };
  }

  return { ok: false, state: null };
}

export function registerOrchestratorStateRoute(app) {
  if (!app || typeof app.get !== "function") {
    throw new Error("registerOrchestratorStateRoute(app) requires an Express app");
  }

  app.get("/orchestrator/state", (req, res) => {
    if (!truthy(process.env.PHASE19_ENABLE_ORCH_STATE)) {
      return res.status(404).json({ ok: false, error: "not_found" });
    }

    const enabled = truthy(process.env.PHASE18_ENABLE_ORCHESTRATION);

    const { ok, state } = readStateFromGlobals();
    const payload = {
      ok: true,
      enabled,
      available: ok,
      ts: Date.now(),
      state: ok ? safeClone(state) : null,
      note: ok ? undefined : "orchestrator state not found on expected globals",
    };

    return res.status(200).json(payload);
  });
}
JS

SERVER_FILE="server.mjs"
if [[ ! -f "$SERVER_FILE" ]]; then
  echo "ERROR: $SERVER_FILE not found at repo root."
  exit 1
fi

# 1) Ensure import is present (idempotent)
perl -0777 -i -pe '
  my $imp = "import { registerOrchestratorStateRoute } from \"./server/orchestrator_state_route.mjs\";\n";
  if ($_ !~ /\Q$imp\E/) {
    if ($_ =~ /\nconst\s+app\s*=\s*express\(\)\s*;\s*\n/s) {
      # Insert after the last top-level import line (best effort)
      if ($_ =~ /(\A(?:import[^\n]*\n)+)/s) {
        $_ =~ s/(\A(?:import[^\n]*\n)+)/$1$imp/s;
      } else {
        $_ = $imp . $_;
      }
    } else {
      # still try to add after imports
      if ($_ =~ /(\A(?:import[^\n]*\n)+)/s) {
        $_ =~ s/(\A(?:import[^\n]*\n)+)/$1$imp/s;
      } else {
        $_ = $imp . $_;
      }
    }
  }
' "$SERVER_FILE"

perl -0777 -i -pe '
  if ($_ !~ /registerOrchestratorStateRoute\(app\)\s*;/) {
    # Insert immediately after `const app = express();`
    $_ =~ s/(const\s+app\s*=\s*express\(\)\s*;\s*\n)/$1registerOrchestratorStateRoute(app);\n/s;
  }
' "$SERVER_FILE"

echo "=== Quick sanity checks ==="
node -c "$SERVER_FILE" >/dev/null 2>&1 || true
node -c server/orchestrator_state_route.mjs >/dev/null 2>&1 || true

echo
echo "=== Grep: new endpoint + gate ==="
rg -n "PHASE19_ENABLE_ORCH_STATE|/orchestrator/state|registerOrchestratorStateRoute" "$SERVER_FILE" server/orchestrator_state_route.mjs

echo
echo "=== Done. Next: run server with PHASE19_ENABLE_ORCH_STATE=1 and curl /orchestrator/state ==="
