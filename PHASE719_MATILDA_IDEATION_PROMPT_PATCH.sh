
#!/usr/bin/env bash

set -euo pipefail

rm -f PHASE719_MATILDA_HELPFULNESS_INSPECTION.sh

rm -f PHASE719_MINIMAL_MATILDA_REFUSAL_TRACE.sh

python3 - <<'PY'

from pathlib import Path

targets = [Path("server.js"), Path("server.mjs")]

needle = '''    "You may explain, interpret, summarize, and reason conversationally.",'''

insert = '''    "You may help the user brainstorm, ideate, scope, plan, compare options, and explain what kinds of projects could be built with the system.",

    "When the user asks what they can build, asks for project ideas, or asks whether a project is possible, answer helpfully with concrete suggestions and safe next steps.",

    "Do not refuse ordinary brainstorming or planning questions merely because chat itself cannot execute actions.",

    "Clearly distinguish between advising/planning from chat and executing work through explicit task/delegation pathways.",'''

for path in targets:

    text = path.read_text()

    if "Do not refuse ordinary brainstorming or planning questions" in text:

        print(f"already patched: {path}")

        continue

    if needle not in text:

        raise SystemExit(f"Expected prompt anchor not found in {path}; aborting.")

    text = text.replace(needle, needle + "\n" + insert, 1)

    path.write_text(text)

    print(f"patched: {path}")

PY

node --check server.js

node --check server.mjs

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/chat/context >/dev/null || true

git add -A

git commit -m "Phase 719: make Matilda helpful for project ideation"

git push origin dev

