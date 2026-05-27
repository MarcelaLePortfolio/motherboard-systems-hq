#!/usr/bin/env bash
set -euo pipefail
cd "$(cd "$(dirname "$0")/.." && pwd)"

FILE="server.mjs"
[[ -f "$FILE" ]] || { echo "ERROR: server.mjs not found"; exit 1; }

perl -0777 -i -pe '
  sub has { my ($re,$s)=@_; return $s =~ /$re/s; }

  # Ensure JSON parsing is enabled (safe if already present)
  if (!has(qr/\bapp\.use\(\s*express\.json\(\)\s*\)\s*;/, $_)) {
    s/(const\s+app\s*=\s*express\(\)\s*;\s*\n)/$1app.use(express.json());\n/s;
  }

  # Ensure reflections hub exists (don’t redeclare hub function; just ensure the object exists)
  if (!has(qr/__SSE\.reflections/, $_)) {
    s/(if\s*\(!globalThis\.__SSE\)\s*globalThis\.__SSE\s*=\s*\{\};\s*\n)/$1  if (!globalThis.__SSE.reflections) globalThis.__SSE.reflections = _phase16CreateSSEHub("reflections");\n/s;
  }

  # Add API route if missing
  if (!has(qr/app\.post\(\s*["'"'"']\/api\/reflections\/signal["'"'"']/, $_)) {
    my $api = <<'"'"'API'"'"';

  // ===== PHASE16_REFLECTIONS_SIGNAL_API =====
  function _phase16BroadcastReflection(type, payload) {
    const msg = { type, ts: Date.now(), payload };
    if (globalThis.__SSE && globalThis.__SSE.reflections && globalThis.__SSE.reflections.broadcast) {
      globalThis.__SSE.reflections.broadcast(msg, type);
    }
    return msg;
  }

  app.post("/api/reflections/signal", (req, res) => {
    const body = (req && req.body) || {};
    const type = String(body.type || "reflections.signal");
    const payload = body.payload || body;
    _phase16BroadcastReflection(type, payload);
    res.json({ ok: true });
  });
  // =========================================

API

    s/(app\.listen\([^\n]*\);\s*)/$api\n$1/s
      or $_ .= "\n$api\n";
  }

  $_;
' "$FILE"

echo "✅ Patched server.mjs with /api/reflections/signal"
