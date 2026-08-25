#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("server/routes/governance-delegation-route.ts")
text = path.read_text()

old = '''    delegation_id: normalizeText(body.delegation_id),

    package_id: normalizeText(body.package_id),'''

new = '''    delegation_id: normalizeText(body.delegation_id),

    project_id: normalizeText(body.project_id),

    package_id: normalizeText(body.package_id),'''

if old not in text:
    raise SystemExit("Expected governance Delegation route request fragment not found.")

path.write_text(text.replace(old, new, 1))
PY

git diff --check
git add server/routes/governance-delegation-route.ts
git commit -m "Transport project scope through Delegation route"
git push

npx tsc --noEmit --pretty false
