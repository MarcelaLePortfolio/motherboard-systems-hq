#!/bin/bash
set -euo pipefail

echo "PHASE 705 — RESTORE FULL SERVER SURFACE + PATCH CHAT ONLY"

BASE_COMMIT="c7495b8c"

git show "${BASE_COMMIT}:server.mjs" > server.mjs
git show "${BASE_COMMIT}:server.js" > server.js

python3 - << 'PY'
from pathlib import Path

def patch_file(path: str, quote: str):
    p = Path(path)
    s = p.read_text()

    marker = "app.post('/api/chat'" if quote == "'" else 'app.post("/api/chat"'
    start = s.find(marker)
    if start == -1:
        raise SystemExit(f"Could not find chat route in {path}")

    next_marker = "\n\napp." 
    end = s.find(next_marker, start + 1)
    if end == -1:
        raise SystemExit(f"Could not find end of chat route in {path}")

    if quote == "'":
        block = """app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body || {};
    const message = typeof body.message === 'string' ? body.message : '';
    const input = typeof body.input === 'string' ? body.input : message;
    const normalized = String(input || '').trim();

    let reply;

    if (!normalized) {
      reply = 'Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.';
    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {
      reply = 'I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.';
    } else if (/boundary|boundaries|can.*do|cannot|can\\'t|what.*do/i.test(normalized)) {
      reply = 'I can provide advisory guidance, summarize visible system state, explain dashboard signals, and clarify operational next steps. I cannot execute tasks, mutate the database, trigger workers, or change infrastructure from chat.';
    } else if (/who are you|what are you|purpose|matilda/i.test(normalized)) {
      reply = 'I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.';
    } else {
      reply = 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';
    }

    res.json({
      reply,
      meta: {
        mode: 'advisory-deterministic',
        execution: false,
        systemCoupling: false
      }
    });
  } catch (err) {
    console.error('Error in /api/chat:', err);
    res.status(500).json({
      reply: 'Advisory response only: chat route error. No execution performed.',
      meta: {
        mode: 'advisory-deterministic',
        execution: false,
        systemCoupling: false
      }
    });
  }
});"""
    else:
        block = """app.post("/api/chat", (req, res) => {
  try {
    const body = req.body || {};
    const message = typeof body.message === "string" ? body.message : "";
    const input = typeof body.input === "string" ? body.input : message;
    const normalized = String(input || "").trim();

    let reply;

    if (!normalized) {
      reply = "Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.";
    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {
      reply = "I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.";
    } else if (/boundary|boundaries|can.*do|cannot|can't|what.*do/i.test(normalized)) {
      reply = "I can provide advisory guidance, summarize visible system state, explain dashboard signals, and clarify operational next steps. I cannot execute tasks, mutate the database, trigger workers, or change infrastructure from chat.";
    } else if (/who are you|what are you|purpose|matilda/i.test(normalized)) {
      reply = "I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.";
    } else {
      reply = "Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.";
    }

    return res.json({
      reply,
      meta: {
        mode: "advisory-deterministic",
        execution: false,
        systemCoupling: false
      }
    });
  } catch (err) {
    console.error("Error in /api/chat:", err);
    return res.status(500).json({
      reply: "Advisory response only: chat route error. No execution performed.",
      meta: {
        mode: "advisory-deterministic",
        execution: false,
        systemCoupling: false
      }
    });
  }
});"""

    p.write_text(s[:start] + block + s[end:])

patch_file("server.mjs", "'")
patch_file("server.js", '"')
PY

docker compose up -d --build dashboard

sleep 8

echo ""
echo "[1] Chat validation"
curl -sS -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are your execution boundaries?"}' | jq .

echo ""
echo "[2] Server size restored"
wc -l server.mjs server.js

echo ""
echo "[3] Task endpoint still present"
grep -n "api/tasks\\|events/task-events\\|api/guidance" server.mjs server.js | head -30

git add server.mjs server.js PHASE705_RESTORE_SERVER_AND_PATCH_CHAT.sh
git commit -m "Phase 705: restore server surface and patch advisory chat only"
git push
