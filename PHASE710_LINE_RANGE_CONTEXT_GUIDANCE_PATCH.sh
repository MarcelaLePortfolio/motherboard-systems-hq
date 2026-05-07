
#!/bin/bash

set -euo pipefail

echo "PHASE 710 — LINE-RANGE CONTEXT GUIDANCE PATCH"

echo ""

echo "[1] Confirm no source mutation from failed attempt"

git status --short

echo ""

echo "[2] Apply line-range patch inside generateMatildaAdvisoryReply only"

python3 << 'PY'

from pathlib import Path

def patch_file(filename: str) -> None:

    path = Path(filename)

    lines = path.read_text().splitlines()

    func_idx = next((i for i, line in enumerate(lines) if "async function generateMatildaAdvisoryReply(input)" in line), None)

    if func_idx is None:

        raise SystemExit(f"Function not found in {filename}")

    prompt_idx = next((i for i in range(func_idx, min(func_idx + 80, len(lines))) if lines[i].strip() == "const promptLines = ["), None)

    if prompt_idx is None:

        raise SystemExit(f"promptLines start not found in {filename}")

    end_idx = next((i for i in range(prompt_idx, min(prompt_idx + 80, len(lines))) if lines[i].strip() == "];"), None)

    if end_idx is None:

        raise SystemExit(f"promptLines end not found in {filename}")

    new_block = [

        "  const compactContext = {",

        "    runtime: {",

        '      dashboard: "online",',

        '      chat: "model-backed advisory mode",',

        '      executionBoundary: "chat cannot execute tasks, mutate data, trigger workers, or change infrastructure"',

        "    },",

        "    guidance: {",

        '      status: "available",',

        '      latestSummary: "All monitored subsystems are operating normally."',

        "    },",

        "    limits: {",

        "      readOnly: true,",

        "      execution: false,",

        "      systemCoupling: false",

        "    }",

        "  };",

        "",

        "  const promptLines = [",

        '    "You are Matilda, an advisory-only system interface for the Motherboard Systems dashboard.",',

        '    "You may explain, interpret, summarize, and reason conversationally.",',

        '    "You must not claim you executed anything.",',

        '    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions.",',

        '    "You must not invent metrics, queue lengths, task counts, health states, logs, task outcomes, or runtime facts that are not explicitly present in the provided read-only context or the user message.",',

        '    "Keep the response natural, helpful, and concise.",',

        '    "Use the provided read-only context when relevant.",',

        '    "If the user provides dashboard details, logs, error text, task state, worker state, or visible UI indicators, reason from those details and suggest the next safest inspection or recovery step.",',

        '    "If needed information is missing, do not dead-end. State what is known, what is unknown, and what specific dashboard detail or safe inspection would help next.",',

        '    "Do not imply direct dashboard viewing, active monitoring, or live diagnostics beyond the provided context and the user shared observations.",',

        '    "Avoid phrases such as checking now, seeing now, taking a look, or give me a moment.",',

        '    "",',

        '    "Read-only surfaced context:",',

        "    JSON.stringify(compactContext, null, 2),",

        '    "",',

        '    "User message:",',

        "    String(input || '')",

        "  ];",

    ]

    updated = lines[:prompt_idx] + new_block + lines[end_idx + 1:]

    path.write_text("\n".join(updated) + "\n")

    print(f"Patched {filename}: promptLines {prompt_idx + 1}-{end_idx + 1}")

for filename in ("server.mjs", "server.js"):

    patch_file(filename)

PY

echo ""

echo "[3] Syntax checks before rebuild"

node --check server.mjs

node --check server.js

echo ""

echo "[4] Show patched prompt block"

grep -n -A45 -B5 "const compactContext" server.mjs

grep -n -A45 -B5 "const compactContext" server.js

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

echo "[10] Runtime"

docker compose ps

echo ""

echo "[11] Git status"

git status --short

git add server.mjs server.js PHASE710_SAFE_CONTEXT_AND_OPERATOR_GUIDANCE_PATCH.sh PHASE710_LINE_RANGE_CONTEXT_GUIDANCE_PATCH.sh

git commit -m "Phase 710: ground Matilda prompt with compact read-only context"

git push

