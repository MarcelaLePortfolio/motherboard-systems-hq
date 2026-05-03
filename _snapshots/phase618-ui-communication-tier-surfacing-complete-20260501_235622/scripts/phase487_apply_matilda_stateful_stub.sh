#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — APPLY MATILDA STATE-AWARE STUB"
echo "────────────────────────────────"

python3 - << 'PY'
from pathlib import Path

path = Path("server.mjs")
text = path.read_text()

start = text.find('app.post("/api/chat"')
if start == -1:
    raise SystemExit("ERROR: /api/chat route not found")

end = text.find('});', start)
if end == -1:
    raise SystemExit("ERROR: could not locate end of /api/chat block")
end += 3

replacement = '''app.post("/api/chat", async (req, res) => {
  try {
    const rawMessage =
      req.body?.message ??
      req.body?.prompt ??
      req.body?.text ??
      "";

    const message = String(rawMessage || "").trim();

    const fetchJson = async (url) => {
      try {
        const r = await fetch(url);
        if (!r.ok) return null;
        return await r.json();
      } catch {
        return null;
      }
    };

    const [health, tasks] = await Promise.all([
      fetchJson("http://localhost:3000/diagnostics/system-health"),
      fetchJson("http://localhost:3000/api/tasks"),
    ]);

    let healthSummary = "System state unavailable.";
    if (health && typeof health.situationSummary === "string") {
      healthSummary = health.situationSummary.trim();
    }

    let taskSummary = "No recent tasks.";
    if (tasks && Array.isArray(tasks.tasks) && tasks.tasks.length > 0) {
      const t = tasks.tasks[0];
      const title = t.title || "Untitled task";
      const status = (t.status || "unknown").replace("_", " ");
      taskSummary = `Latest task: ${title} (status: ${status})`;
    }

    const replyParts = [];

    if (message) {
      replyParts.push(`You said: "${message}"`);
    }

    replyParts.push(healthSummary);
    replyParts.push(taskSummary);

    return res.json({
      ok: true,
      agent: "matilda",
      mode: "phase487-state-aware-readonly",
      reply: replyParts.join("\\n\\n"),
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      agent: "matilda",
      mode: "phase487-state-aware-readonly",
      error: error instanceof Error ? error.message : "Unknown chat error",
    });
  }
});'''

new_text = text[:start] + replacement + text[end:]
path.write_text(new_text)

print("PATCHED: server.mjs")
PY

git add server.mjs
git commit -m "PHASE 487: upgrade Matilda to deterministic state-aware read-only responses"
git push

docker compose up -d --build

curl -s -X POST http://localhost:8080/api/chat \
  -H 'Content-Type: application/json' \
  --data '{"message":"Status check after cognition upgrade"}'
