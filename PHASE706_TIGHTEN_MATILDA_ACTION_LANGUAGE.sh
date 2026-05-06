
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — TIGHTEN MATILDA ACTION-LANGUAGE GUARDRAILS"

python3 - << 'PY'

from pathlib import Path

for file in ["server.mjs", "server.js"]:

    p = Path(file)

    s = p.read_text()

    if "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, or performed infrastructure actions." not in s:

        raise SystemExit(f"Expected Matilda prompt text not found in {file}")

    s = s.replace(

        "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, or performed infrastructure actions.",

        "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions."

    )

    s = s.replace(

        "Keep the response natural, helpful, and concise.",

        "Keep the response natural, helpful, and concise. If the user asks for a systems check, explain that you can interpret visible dashboard state if provided, but you are not actively checking or gathering anything."

    )

    p.write_text(s)

PY

echo ""

echo "[1] Rebuild dashboard"

docker compose up -d --build dashboard

echo ""

echo "[2] Wait"

sleep 12

echo ""

echo "[3] Validate systems-check wording"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[4] Validate execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[5] Runtime"

docker compose ps

git add server.mjs server.js PHASE706_TIGHTEN_MATILDA_ACTION_LANGUAGE.sh

git commit -m "Phase 706: tighten Matilda action-language guardrails"

git push

