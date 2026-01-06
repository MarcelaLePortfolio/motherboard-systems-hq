
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FILE="server.mjs"
if [[ ! -f "$FILE" ]]; then
  echo "ERROR: server.mjs not found at repo root: $ROOT" >&2
  exit 1
fi

perl -0777 -i -pe '
  sub has { my ($re,$s)=@_; return $s =~ /$re/s; }

  # 1) Ensure JSON body parsing
  if (!has(qr/\bapp\.use\(\s*express\.json\(\)\s*\)\s*;/, $_)) {
    if (s/(const\s+app\s*=\s*express\(\)\s*;\s*\n)/$1app.use(express.json());\n/s) {
    } elsif (s/(app\.use\([^\n]*express\.static[^\n]*\);\s*\n)/$1app.use(express.json());\n/s) {
    } else {
      $_ = "/* phase16: injected express.json */\napp.use(express.json());\n\n" . $_;
    }
  }

  # 2) SSE hub + globalThis.__SSE
  if (!has(qr/PHASE16_SSE_HUB/, $_)) {
    my $inject = <<'"'"'INJECT'"'"';

  // ===== PHASE16_SSE_HUB (OPS + Reflections) =====
  function _phase16CreateSSEHub(name) {
    const hub = {
      name,
      clients: new Set(),
      last: null,
      nextId: 1,
      broadcast(payload, eventName) {
        const id = String(this.nextId++);
        const data = typeof payload === "string" ? payload : JSON.stringify(payload);
        const event = eventName || "message";
        const frame = `id: ${id}\nevent: ${event}\ndata: ${data}\n\n`;
        this.last = { id, data, event };
        for (const res of this.clients) {
          try { res.write(frame); } catch (_) {}
        }
        return id;
      },
      attach(res) {
        this.clients.add(res);
        res.on("close", () => this.clients.delete(res));
        try { res.write(`: connected ${name}\n\n`); } catch (_) {}
        if (this.last) {
          try {
            res.write(`id: ${this.last.id}\nevent: ${this.last.event}\ndata: ${this.last.data}\n\n`);
          } catch (_) {}
        }
      },
    };
    return hub;
  }

  if (!globalThis.__SSE) globalThis.__SSE = {};
  if (!globalThis.__SSE.ops) globalThis.__SSE.ops = _phase16CreateSSEHub("ops");
  if (!globalThis.__SSE.reflections) globalThis.__SSE.reflections = _phase16CreateSSEHub("reflections");

  if (!globalThis.__OPS_STATE) {
    globalThis.__OPS_STATE = { status: "unknown", lastHeartbeatAt: null, agents: {} };
  }
  // ==============================================

INJECT

    if (!s/(const\s+app\s*=\s*express\(\)\s*;\s*\n)/$1$inject/s) {
      $_ = $inject . "\n" . $_;
    }
  }

  # 3) SSE endpoints
  if (!has(qr/app\.get\(\s*["'"'"']\/events\/ops["'"'"']/, $_)) {
    my $sseRoutes = <<'"'"'ROUTES'"'"';

  // ===== PHASE16_SSE_ROUTES =====
  function _phase16SSEHeaders(res) {
    res.status(200);
    res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    res.setHeader("Connection", "keep-alive");
    res.setHeader("X-Accel-Buffering", "no");
    if (res.flushHeaders) res.flushHeaders();
  }

  app.get("/events/ops", (req, res) => {
    _phase16SSEHeaders(res);
    globalThis.__SSE.ops.attach(res);
  });

  app.get("/events/reflections", (req, res) => {
    _phase16SSEHeaders(res);
    globalThis.__SSE.reflections.attach(res);
  });
  // =============================

ROUTES

    s/(app\.listen\([^\n]*\);\s*)/$sseRoutes\n$1/s;
  }

  # 4) OPS ingest
  if (!has(qr/PHASE16_OPS_SIGNAL_INGEST/, $_)) {
    my $opsIngest = <<'"'"'OPS'"'"';

  // ===== PHASE16_OPS_SIGNAL_INGEST =====
  function _phase16Now() { return Date.now(); }

  function _phase16BroadcastOps(type, payload) {
    const msg = { type, ts: _phase16Now(), payload };
    globalThis.__SSE.ops.broadcast(msg, type);
    return msg;
  }

  app.post("/api/ops/heartbeat", (req, res) => {
    const body = (req && req.body) || {};
    const source = String(body.source || body.agent || body.from || "unknown");
    const ts = _phase16Now();

    globalThis.__OPS_STATE.status = "live";
    globalThis.__OPS_STATE.lastHeartbeatAt = ts;

    _phase16BroadcastOps("ops.heartbeat", { source, at: ts, meta: body.meta || body });
    res.json({ ok: true, status: globalThis.__OPS_STATE.status, at: ts });
  });

  app.post("/api/ops/agent-status", (req, res) => {
    const body = (req && req.body) || {};
    const agent = String(body.agent || body.name || "unknown");
    const state = String(body.state || body.status || "unknown");
    const ts = _phase16Now();

    globalThis.__OPS_STATE.status = "live";
    globalThis.__OPS_STATE.agents[agent] = { state, at: ts, meta: body.meta || body };

    _phase16BroadcastOps("ops.agent_status", { agent, state, at: ts, meta: body.meta || body });
    res.json({ ok: true, agent, state, at: ts });
  });

  app.get("/api/ops/state", (req, res) => {
    res.json({ ok: true, state: globalThis.__OPS_STATE });
  });
  // ====================================

OPS

    s/(app\.listen\([^\n]*\);\s*)/$opsIngest\n$1/s;
  }

  # 5) Reflections pattern (mirrored)
  if (!has(qr/PHASE16_REFLECTIONS_SIGNAL_PATTERN/, $_)) {
    my $refl = <<'"'"'REFL'"'"';

  // ===== PHASE16_REFLECTIONS_SIGNAL_PATTERN =====
  function _phase16BroadcastReflection(type, payload) {
    const msg = { type, ts: Date.now(), payload };
    globalThis.__SSE.reflections.broadcast(msg, type);
    return msg;
  }

  app.post("/api/reflections/signal", (req, res) => {
    const body = (req && req.body) || {};
    const type = String(body.type || "reflections.signal");
    const payload = body.payload || body;
    _phase16BroadcastReflection(type, payload);
    res.json({ ok: true });
  });
  // =============================================

REFL

    s/(app\.listen\([^\n]*\);\s*)/$refl\n$1/s;
  }

  $_;
' "$FILE"

chmod +x scripts/phase16_ops_reflections_wiring_patch.sh
echo "✅ Phase16 patch applied to server.mjs"
