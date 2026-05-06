
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — CONTEXTUAL MATILDA ADVISORY PATCH"

python3 - << 'PY'

from pathlib import Path

patches = {

    "server.mjs": {

        "needle": """    } else if (/who are you|what are you|purpose|matilda/i.test(normalized)) {

      reply = 'I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.';

    } else {

      reply = 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';

    }""",

        "replacement": """    } else if (/who are you|what are you|purpose|matilda/i.test(normalized)) {

      reply = 'I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.';

    } else if (/dashboard|inspector|idle|waiting|status|healthy|runtime/i.test(normalized)) {

      reply = 'Advisory interpretation: an idle inspector can be healthy when the runtime is connected but no new task event is currently streaming. Check container health, SSE connection state, and recent task events before treating idle status as a failure. No execution has been performed.';

    } else if (/storage|disk|backup|snapshot|external|hard drive|ssd/i.test(normalized)) {

      reply = 'Advisory interpretation: storage-safe progress means keeping source changes in Git while placing heavy archives, snapshots, and exports on the external SSD. Avoid committing large binary artifacts, and validate disk/Docker usage before rebuild-heavy work. No execution has been performed.';

    } else {

      reply = 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';

    }"""

    },

    "server.js": {

        "needle": """    } else if (/who are you|what are you|purpose|matilda/i.test(normalized)) {

      reply = "I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.";

    } else {

      reply = "Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.";

    }""",

        "replacement": """    } else if (/who are you|what are you|purpose|matilda/i.test(normalized)) {

      reply = "I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.";

    } else if (/dashboard|inspector|idle|waiting|status|healthy|runtime/i.test(normalized)) {

      reply = "Advisory interpretation: an idle inspector can be healthy when the runtime is connected but no new task event is currently streaming. Check container health, SSE connection state, and recent task events before treating idle status as a failure. No execution has been performed.";

    } else if (/storage|disk|backup|snapshot|external|hard drive|ssd/i.test(normalized)) {

      reply = "Advisory interpretation: storage-safe progress means keeping source changes in Git while placing heavy archives, snapshots, and exports on the external SSD. Avoid committing large binary artifacts, and validate disk/Docker usage before rebuild-heavy work. No execution has been performed.";

    } else {

      reply = "Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.";

    }"""

    }

}

for file, data in patches.items():

    path = Path(file)

    text = path.read_text()

    if data["needle"] not in text:

        raise SystemExit(f"Needle not found in {file}")

    path.write_text(text.replace(data["needle"], data["replacement"]))

PY

echo ""

echo "[1] Rebuild dashboard only"

docker compose up -d --build dashboard

echo ""

echo "[2] Wait"

sleep 12

echo ""

echo "[3] Validate dashboard/inspector advisory response"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"How should I interpret the dashboard if the inspector is idle?"}' | jq .

echo ""

echo "[4] Validate execution refusal still intact"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Please restart the worker and run a task."}' | jq .

echo ""

echo "[5] Validate runtime"

docker compose ps

echo ""

echo "[6] Validate storage"

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

git add server.mjs server.js PHASE706_CONTEXTUAL_ADVISORY_PATCH.sh

git commit -m "Phase 706: improve contextual Matilda advisory responses"

git push

