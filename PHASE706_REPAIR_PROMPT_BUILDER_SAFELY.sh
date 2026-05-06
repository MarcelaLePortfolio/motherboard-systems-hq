
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — REPAIR MATILDA PROMPT BUILDER SAFELY"

python3 - << 'PY'

from pathlib import Path

import re

PROMPT_LINES = [

    "You are Matilda, an advisory-only system interface for the Motherboard Systems dashboard.",

    "You may explain, interpret, summarize, and reason conversationally.",

    "You must not claim you executed anything.",

    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions.",

    "Keep the response natural, helpful, and concise.",

    "If the user asks for a systems check, explain that you can interpret dashboard information they provide or surfaced state included in the chat context.",

    "Do not imply direct dashboard viewing, active monitoring, live status gathering, or diagnostics unless read-only context has actually been provided.",

    "Avoid phrases such as checking now, seeing now, taking a look, or give me a moment.",

    "",

    "User message:"

]

def js_string(value):

    import json

    return json.dumps(value)

def replacement_block():

    lines = ["const promptLines = ["]

    for item in PROMPT_LINES:

        lines.append(f"    {js_string(item)},")

    lines.append("    String(input || '')")

    lines.append("  ];")

    lines.append("")

    lines.append("  const prompt = promptLines.join('\\n');")

    return "\n".join(lines)

def repair(path_str):

    path = Path(path_str)

    s = path.read_text()

    start = s.find("const prompt")

    if start == -1:

        raise SystemExit(f"Could not find const prompt in {path_str}")

    # Replace either a broken const prompt block or promptLines block through controller declaration.

    controller = s.find("  const controller = new AbortController();", start)

    if controller == -1:

        raise SystemExit(f"Could not find controller after prompt in {path_str}")

    new_s = s[:start] + replacement_block() + "\n\n" + s[controller:]

    path.write_text(new_s)

repair("server.mjs")

repair("server.js")

PY

echo ""

echo "[1] Syntax check before rebuild"

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

echo "[4] Validate systems-check wording"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[5] Validate natural chat"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Hello Matilda."}' | jq .

echo ""

echo "[6] Validate execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[7] Runtime"

docker compose ps

git add server.mjs server.js PHASE706_TIGHTEN_VISIBLE_CONTEXT_LANGUAGE.sh PHASE706_FIX_PROMPT_QUOTE_CRASH.sh PHASE706_FIX_ALL_PROMPT_QUOTES.sh PHASE706_REPAIR_PROMPT_BUILDER_SAFELY.sh

git commit -m "Phase 706: repair Matilda prompt builder safely"

git push

