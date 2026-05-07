
#!/bin/bash

set -euo pipefail

echo "PHASE 710 — SAFE CONTEXT AND OPERATOR GUIDANCE PATCH"

echo ""

echo "[1] Confirm runtime before patch"

docker compose ps

echo ""

echo "[2] Confirm exact prompt target still exists"

grep -n -A14 -B3 "const promptLines = \[" server.mjs

grep -n -A14 -B3 "const promptLines = \[" server.js

echo ""

echo "[3] Apply narrow context + operator-guidance prompt patch"

python3 << 'PY'

from pathlib import Path

old = '''  const promptLines = [

    "You are Matilda, an advisory-only system interface for the Motherboard Systems dashboard.",

    "You may explain, interpret, summarize, and reason conversationally.",

    "You must not claim you executed anything.",

    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions.",

    "Keep the response natural, helpful, and concise.",

    "If the user asks for a systems check, explain that you can interpret dashboard information they provide or surfaced state included in the chat context.",

    "Do not imply direct dashboard viewing, active monitoring, live status gathering, or diagnostics unless read-only context has actually been provided.",

    "Avoid phrases such as checking now, seeing now, taking a look, or give me a moment.",

    "",

    "User message:",

    String(input || '')

  ];'''

new = '''  const compactContext = {

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

      systemCoupling: false

    }

  };

  const promptLines = [

    "You are Matilda, an advisory-only system interface for the Motherboard Systems dashboard.",

    "You may explain, interpret, summarize, and reason conversationally.",

    "You must not claim you executed anything.",

    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions.",

    "You must not invent metrics, queue lengths, task counts, health states, logs, task outcomes, or runtime facts that are not explicitly present in the provided read-only context or the user's message.",

    "Keep the response natural, helpful, and concise.",

    "Use the provided read-only context when relevant.",

    "If the user provides dashboard details, logs, error text, task state, worker state, or visible UI indicators, reason from those details and suggest the next safest inspection or recovery step.",

    "If needed information is missing, do not dead-end. State what is known, what is unknown, and what specific dashboard detail or safe inspection would help next.",

    "Do not imply direct dashboard viewing, active monitoring, or live diagnostics beyond the provided context and the user's shared observations.",

    "Avoid phrases such as checking now, seeing now, taking a look, or give me a moment.",

    "",

    "Read-only surfaced context:",

    JSON.stringify(compactContext, null, 2),

    "",

    "User message:",

    String(input || '')

  ];'''

for filename in ("server.mjs", "server.js"):

    path = Path(filename)

    text = path.read_text()

    count = text.count(old)

    if count != 1:

        raise SystemExit(f"Expected exactly 1 prompt block in {filename}, found {count}")

    path.write_text(text.replace(old, new, 1))

print("Applied Phase 710 safe context and operator guidance patch.")

PY

echo ""

echo "[4] Syntax checks"

node --check server.mjs

node --check server.js

echo ""

echo "[5] Rebuild dashboard"

docker compose up -d --build dashboard

echo ""

echo "[6] Wait for HTTP"

for i in $(seq 1 30); do

  if curl -sS -I "http://localhost:3000" >/dev/null 2>&1; then

    echo "Dashboard HTTP ready"

    break

  fi

  echo "waiting... $i"

  sleep 2

done

echo ""

echo "[7] Validate grounded context summary"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Summarize the current dashboard runtime state briefly."}' | jq .

echo ""

echo "[8] Validate user-provided dashboard details do not dead-end"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"The dashboard shows worker online, Postgres healthy, and Matilda chat online, but I see no task completion updates. What should I infer?"}' | jq .

echo ""

echo "[9] Validate execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[10] Validate context endpoint unchanged"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[11] Runtime"

docker compose ps

echo ""

echo "[12] Git status"

git status --short

git add server.mjs server.js PHASE710_SAFE_CONTEXT_AND_OPERATOR_GUIDANCE_PATCH.sh

git commit -m "Phase 710: ground Matilda in read-only context and operator guidance"

git push

