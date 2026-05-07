
#!/bin/bash

set -euo pipefail

echo "PHASE 709 — FIX INSPECTION CURL AND CAPTURE FINDING"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Finding: prompt assembly currently does not inject /api/chat/context"

grep -n -A25 -B5 "async function generateMatildaAdvisoryReply" server.mjs

echo ""

echo "[3] Context endpoint is available"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[4] Backend advisory response with fixed single-line curl"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Summarize the current dashboard runtime state briefly."}' | jq .

echo ""

echo "[5] Record finding"

cat > PHASE709_PROMPT_ASSEMBLY_FINDING.md << 'FINDING'

# Phase 709 Prompt Assembly Finding

The live `/api/chat/context` endpoint is available and returns compact read-only runtime context.

However, `generateMatildaAdvisoryReply(input)` currently builds `promptLines` from static advisory instructions plus the user message only. It does not inject the `/api/chat/context` payload or an equivalent compact context object into the Ollama prompt.

Result:

- Matilda remains advisory-safe.

- Matilda can mention that surfaced context may exist.

- Matilda cannot reliably summarize the actual current dashboard runtime state from the prompt.

- Next safe implementation should inject a compact static/read-only context block into `promptLines` without changing execution behavior.

Constraints:

- Do not re-enter the failed broad prompt-builder patch approach.

- Patch only a small helper/context string if attempted.

- Keep all curls single-line in scripts.

- Preserve advisory-only and non-executing boundaries.

FINDING

echo ""

echo "[6] Git status"

git status --short

git add PHASE709_PROMPT_ASSEMBLY_INSPECTION.sh PHASE709_FIX_INSPECTION_CURL_AND_CAPTURE_FINDING.sh PHASE709_PROMPT_ASSEMBLY_FINDING.md

git commit -m "Phase 709: capture Matilda prompt assembly finding" || true

git push || true

