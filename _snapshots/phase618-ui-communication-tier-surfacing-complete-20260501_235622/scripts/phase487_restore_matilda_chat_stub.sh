#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — RESTORE MATILDA CHAT STUB"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean."
  git status --short
  exit 1
fi

python3 - << 'PY'
from pathlib import Path
import sys

path = Path("server.mjs")
text = path.read_text()

if 'app.post("/api/chat"' in text:
    print("INFO: /api/chat route already exists; no patch applied.")
    sys.exit(0)

anchor = 'app.post("/api/delegate-task", async (req, res) => {\n'
idx = text.find(anchor)
if idx == -1:
    raise SystemExit("ERROR: Could not find /api/delegate-task anchor in server.mjs")

insert = '''app.post("/api/chat", async (req, res) => {
  try {
    const rawMessage =
      req.body?.message ??
      req.body?.prompt ??
      req.body?.text ??
      "";

    const message = String(rawMessage || "").trim();

    return res.json({
      ok: true,
      agent: "matilda",
      mode: "phase487-placeholder-stub",
      reply: message
        ? `Matilda placeholder online. I received: "${message}". State-aware chat is not restored yet.`
        : "Matilda placeholder online. Chat route restored, but state-aware chat is not restored yet.",
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      agent: "matilda",
      mode: "phase487-placeholder-stub",
      error: error instanceof Error ? error.message : "Unknown chat stub error",
    });
  }
});

'''
text = text[:idx] + insert + text[idx:]
path.write_text(text)
print("PATCHED: server.mjs")
PY

git add server.mjs
git commit -m "PHASE 487: restore deterministic Matilda placeholder chat route"
git push

docker compose up -d --build

curl -i -s -X POST http://localhost:8080/api/chat \
  -H 'Content-Type: application/json' \
  --data '{"message":"Quick systems check from dashboard Phase 11.4.","agent":"matilda"}' \
  | sed -n '1,80p'
