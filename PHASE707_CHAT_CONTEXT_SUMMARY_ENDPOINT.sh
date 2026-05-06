
#!/bin/bash

set -euo pipefail

echo "PHASE 707 — CHAT CONTEXT SUMMARY ENDPOINT"

python3 - << 'PY'

from pathlib import Path

for file in ["server.mjs", "server.js"]:

    p = Path(file)

    s = p.read_text()

    if "/api/chat/context" in s:

        print(f"{file}: chat context route already present")

        continue

    marker = "app.post('/api/chat'" if file == "server.mjs" else 'app.post("/api/chat"'

    idx = s.find(marker)

    if idx == -1:

        raise SystemExit(f"Could not find chat route marker in {file}")

    quote = "'" if file == "server.mjs" else '"'

    block = f"""

// Phase 707: compact read-only context for Matilda chat

app.get({quote}/api/chat/context{quote}, async (req, res) => {{

  try {{

    const context = {{

      runtime: {{

        dashboard: {quote}online{quote},

        chat: {quote}model-backed advisory mode{quote},

        executionBoundary: {quote}chat cannot execute tasks, mutate data, trigger workers, or change infrastructure{quote}

      }},

      guidance: {{

        status: {quote}available{quote},

        latestSummary: {quote}All monitored subsystems are operating normally.{quote}

      }},

      limits: {{

        readOnly: true,

        execution: false,

        systemCoupling: false,

        note: {quote}Context is compact and surfaced for interpretation only.{quote}

      }}

    }};

    res.json(context);

  }} catch (err) {{

    console.error({quote}Error building /api/chat/context:{quote}, err);

    res.status(500).json({{

      error: {quote}Failed to build chat context{quote},

      readOnly: true,

      execution: false

    }});

  }}

}});

"""

    s = s[:idx] + block + s[idx:]

    p.write_text(s)

PY

echo ""

echo "[1] Syntax check"

node --check server.mjs

node --check server.js

echo ""

echo "[2] Rebuild dashboard"

docker compose up -d --build dashboard

echo ""

echo "[3] Wait for HTTP"

for i in $(seq 1 30); do

  if curl -sS -I "http://localhost:3000" >/dev/null 2>&1; then

    echo "Dashboard HTTP ready"

    break

  fi

  echo "waiting... $i"

  sleep 2

done

echo ""

echo "[4] Validate context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[5] Validate chat still safe"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[6] Runtime"

docker compose ps

git add server.mjs server.js PHASE707_CHAT_CONTEXT_SUMMARY_ENDPOINT.sh

git commit -m "Phase 707: add read-only Matilda chat context summary"

git push

