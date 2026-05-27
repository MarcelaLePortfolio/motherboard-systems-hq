set -euo pipefail
cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

FILE="server.mjs"
[[ -f "$FILE" ]] || { echo "ERROR: server.mjs not found"; exit 1; }

perl -0777 -i -pe '
  sub has { my ($re,$s)=@_; return $s =~ /$re/s; }

  # 1) Helper: broadcast full ops state snapshot (idempotent)
  if (!has(qr/PHASE16_OPS_STATE_SNAPSHOT_BROADCAST_HELPER/, $_)) {
    my $helper = <<'"'"'H'"'"';

  // ===== PHASE16_OPS_STATE_SNAPSHOT_BROADCAST_HELPER =====
  function _phase16BroadcastOpsStateSnapshot(reason) {
    try {
      const st = _phase16GetOpsState();
      const msg = { type: "ops.state", ts: Date.now(), reason: reason || null, payload: st };
      globalThis.__SSE.ops.broadcast(msg, "ops.state");
      return msg;
    } catch (_) {
      return null;
    }
  }
  // ======================================================

H
    s/(\/\/\s*===== PHASE16_OPS_SIGNAL_INGEST =====.*?\n)/$1$helper/s;
  }

  # 2) In /api/ops/heartbeat handler: after updating state, broadcast snapshot
  if (!has(qr/PHASE16_OPS_HEARTBEAT_BROADCASTS_SNAPSHOT/, $_)) {
    s#(app\.post\(\s*["'"'"']\/api\/ops\/heartbeat["'"'"']\s*,\s*\(req,\s*res\)\s*=>\s*\{\s*.*?)(\bstate\.status\s*=\s*["'"'"']live["'"'"']\s*;\s*\n\s*state\.lastHeartbeatAt\s*=\s*Date\.now\(\)\s*;\s*)#$1$2\n    // PHASE16_OPS_HEARTBEAT_BROADCASTS_SNAPSHOT\n    _phase16BroadcastOpsStateSnapshot("heartbeat");\n#s;
  }

  # 3) In /api/ops/agent-status handler: after updating agent info, broadcast snapshot
  if (!has(qr/PHASE16_OPS_AGENT_STATUS_BROADCASTS_SNAPSHOT/, $_)) {
    s#(app\.post\(\s*["'"'"']\/api\/ops\/agent-status["'"'"']\s*,\s*\(req,\s*res\)\s*=>\s*\{\s*.*?)(state\.agents\[agent\]\s*=\s*\{\s*state,\s*at:\s*Date\.now\(\),\s*meta\s*\};\s*\n)#$1$2\n    // PHASE16_OPS_AGENT_STATUS_BROADCASTS_SNAPSHOT\n    _phase16BroadcastOpsStateSnapshot("agent-status");\n#s;
  }

  $_;
' "$FILE"

echo "✅ Patched server.mjs: OPS now broadcasts ops.state snapshots on heartbeat + agent-status"
