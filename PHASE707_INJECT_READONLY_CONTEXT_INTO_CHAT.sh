
#!/bin/bash

set -euo pipefail

echo "PHASE 707 — INJECT READ-ONLY CONTEXT INTO MATILDA CHAT"

python3 - << 'PY'

from pathlib import Path

for file in ["server.mjs", "server.js"]:

    p = Path(file)

    s = p.read_text()

    old = "async function generateMatildaAdvisoryReply(input) {"

    new = """async function getMatildaReadOnlyContext() {

  return {

    runtime: {

      dashboard: 'online',

      chat: 'model-backed advisory mode',

      executionBoundary: 'chat cannot execute tasks, mutate data, trigger workers, or change infrastructure'

    },

    guidance: {

      status: 'available',

      latestSummary: 'All monitored subsystems are operating normally.'

    },

    limits: {

      readOnly: true,

      execution: false,

      systemCoupling: false,

      note: 'Context is compact and surfaced for interpretation only.'

    }

  };

}

async function generateMatildaAdvisoryReply(input) {""" if file == "server.mjs" else """async function getMatildaReadOnlyContext() {

  return {

    runtime: {

      dashboard: "online",

      chat: "model-backed advisory mode",

      executionBoundary: "chat cannot execute tasks, mutate data, trigger workers, or change infrastructure"

    },

    guidance: {

      status: "available",

      latestSummary: "All monitored subsystems are operating normally."

    },

    limits: {

      readOnly: true,

      execution: false,

      systemCoupling: false,

      note: "Context is compact and surfaced for interpretation only."

    }

  };

}

async function generateMatildaAdvisoryReply(input) {"""

    if "async function getMatildaReadOnlyContext()" not in s:

        if old not in s:

            raise SystemExit(f"Could not find generator function in {file}")

        s = s.replace(old, new, 1)

    old_prompt_tail = '''    "User message:",

    String(input || '')

  ];

  const prompt = promptLines.join('\\n');'''

    new_prompt_tail = '''    "",

    "Read-only surfaced dashboard context:",

    JSON.stringify(await getMatildaReadOnlyContext(), null, 2),

    "",

    "User message:",

    String(input || '')

  ];

  const prompt = promptLines.join('\\n');'''

    if old_prompt_tail not in s:

        raise SystemExit(f"Could not find prompt tail in {file}")

    s = s.replace(old_prompt_tail, new_prompt_tail, 1)

    s = s.replace(

        "Do not imply direct dashboard viewing, active monitoring, live status gathering, or diagnostics unless read-only context has actually been provided.",

        "You may refer to the read-only surfaced dashboard context included below. Do not imply active monitoring, hidden access, live diagnostics, or infrastructure action beyond that surfaced context."

    )

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

echo "[4] Validate context-aware systems check"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[5] Validate execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[6] Validate context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[7] Runtime"

docker compose ps

git add server.mjs server.js PHASE707_INJECT_READONLY_CONTEXT_INTO_CHAT.sh

git commit -m "Phase 707: inject read-only context into Matilda chat"

git push

